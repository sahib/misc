package main

import (
	"bytes"
	"fmt"
	"image"
	"image/png"
	_ "image/png"
	"io/ioutil"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"
	"sync"
	"time"

	"log"
	"os"

	"github.com/lucasb-eyer/go-colorful"
	"github.com/urfave/cli/v2"
)

func loadImage(path string) (image.Image, error) {
	fd, err := os.Open(path)
	if err != nil {
		return nil, err
	}

	defer fd.Close()

	img, _, err := image.Decode(fd)
	return img, err
}

func loadImages(paths []string) ([]image.Image, error) {
	imgs := []image.Image{}
	for _, path := range paths {
		img, err := loadImage(path)
		if err != nil {
			return nil, err
		}

		imgs = append(imgs, img)
	}

	return imgs, nil
}

//////////////////////

type BlendOptions struct {
	// How long the blend takes from source to dest.
	AnimationTime time.Duration

	// How many frames per second to render.
	FramesPerSecond int
}

func timeToFrames(dur time.Duration, framesPerSecond int) int {
	return int(float32(dur)/float32(time.Second)) * framesPerSecond
}

func writeFrame(frameDir string, keyIdx, frameIdx int, isKey bool, img image.Image) error {
	var base string
	if isKey {
		base = fmt.Sprintf("frame_%09d_key.png", keyIdx)
	} else {
		base = fmt.Sprintf("frame_%09d_%09d.png", keyIdx, frameIdx)
	}

	path := filepath.Join(frameDir, base)
	fd, err := os.OpenFile(path, os.O_CREATE|os.O_TRUNC|os.O_RDWR, 0644)
	if err != nil {
		return err
	}

	defer fd.Close()
	return png.Encode(fd, img)
}

func blendSrcToDst(opts BlendOptions, frameDir string, src, dst image.Image, keyIdx int) error {
	nFrames := timeToFrames(opts.AnimationTime, opts.FramesPerSecond)
	p := src.Bounds().Size()

	type frameInfo struct {
		index int
		img   image.Image
	}

	frameCh := make(chan frameInfo, 10)

	for frame := 0; frame < nFrames; frame++ {
		go func(frame int) {
			progress := float64(frame) / float64(nFrames)

			// Interpolate exponentially
			progress *= progress

			// Create a new image:
			frameImg := image.NewRGBA(src.Bounds())
			for y := 0; y < p.Y; y++ {
				for x := 0; x < p.X; x++ {
					srcCol, _ := colorful.MakeColor(src.At(x, y))
					dstCol, _ := colorful.MakeColor(dst.At(x, y))
					frameImg.Set(x, y, srcCol.BlendRgb(dstCol, progress))
				}
			}

			frameCh <- frameInfo{
				index: frame,
				img:   frameImg,
			}
		}(frame)
	}

	// Collect the frames and save them on disk:
	for frame := 0; frame < nFrames; frame++ {
		info := <-frameCh
		if err := writeFrame(
			frameDir,
			keyIdx,
			info.index,
			false,
			info.img,
		); err != nil {
			return err
		}
	}

	return writeFrame(frameDir, keyIdx, nFrames, true, dst)
}

func blendOverImages(opts BlendOptions, imgs []image.Image) (string, error) {
	frameDir, err := ioutil.TempDir("", "wallpaper-frames-*")
	if err != nil {
		return "", err
	}

	log.Printf("-- Using temporary directory %s", frameDir)
	blendCh := make(chan int)

	wg := sync.WaitGroup{}

	for workerIdx := 0; workerIdx < 4; workerIdx++ {
		wg.Add(1)

		go func() {
			defer wg.Done()

			for idx := range blendCh {
				log.Printf("-- blending %d/%d", idx+1, len(imgs))
				if err := blendSrcToDst(
					opts,
					frameDir,
					imgs[idx],
					imgs[(idx+1)%len(imgs)],
					idx,
				); err != nil {
					log.Printf("blending failed: %v", err)
				}
			}
		}()
	}

	for idx := range imgs {
		blendCh <- idx
	}

	// Signal worker close:
	close(blendCh)
	wg.Wait()

	return frameDir, nil
}

//////////////////////

type EncodeOptions struct {
	OutputPath      string
	FramesPerSecond int
	KeyDuration     time.Duration
}

func encodeToVideo(opts EncodeOptions, frameDir string) error {
	pngPaths, err := filepath.Glob(filepath.Join(frameDir, "*.png"))
	if err != nil {
		return err
	}

	if len(pngPaths) == 0 {
		return fmt.Errorf("no images given")
	}

	// NOTE: This is lexigraphic sorting, so we nee to pad numbers.
	sort.Strings(pngPaths)

	scriptBuf := &bytes.Buffer{}
	for _, pngPath := range pngPaths {
		fmt.Fprintf(scriptBuf, "file %s\n", pngPath)

		frameDur := time.Second / time.Duration(opts.FramesPerSecond)
		if strings.Contains(filepath.Base(pngPath), "_key") {
			frameDur = opts.KeyDuration
		}

		fmt.Fprintf(scriptBuf, "duration %f\n", float64(frameDur)/float64(time.Second))
	}

	scriptPath := filepath.Join(frameDir, "script.txt")
	err = ioutil.WriteFile(scriptPath, scriptBuf.Bytes(), 0644)
	if err != nil {
		return err
	}

	// There is no go package for that,
	// so just call good old trusty ffmpeg:
	cmd := exec.Command(
		"ffmpeg",
		"-y",
		"-f", "concat",
		"-safe", "0",
		"-i", scriptPath,
		"-qscale:v", "1",
		"-c", "copy",
		opts.OutputPath,
	)

	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

func checkImageSizes(imgs []image.Image) (int, int, error) {
	var prevX, prevY int
	for idx, img := range imgs {
		p := img.Bounds().Size()
		currX, currY := p.X, p.Y

		if idx != 0 {
			if prevX != currX || prevY != currY {
				return -1, -1, fmt.Errorf(
					"image at index %d has a different resolution (%dx%d) then the one before (%dx%d)",
					idx,
					currX, currY,
					prevX, prevY,
				)
			}
		}

		prevX, prevY = currX, currY
	}

	return prevX, prevY, nil
}

//////////////////////

func handleAnimation(ctx *cli.Context) error {
	frameDir := ctx.String("frame-dir")
	if frameDir == "" {
		inputPaths := ctx.StringSlice("input")
		log.Printf("-- Loading %d images", len(inputPaths))

		imgs, err := loadImages(inputPaths)
		if err != nil {
			return err
		}

		x, y, err := checkImageSizes(imgs)
		if err != nil {
			return err
		}

		log.Printf("-- Image resolution is %dx%d", x, y)
		blendOpts := BlendOptions{
			AnimationTime:   ctx.Duration("blend-duration"),
			FramesPerSecond: ctx.Int("frames-per-second"),
		}

		frameDir, err = blendOverImages(blendOpts, imgs)
		if err != nil {
			return err
		}
	}

	encodeOpts := EncodeOptions{
		OutputPath:      ctx.String("output"),
		FramesPerSecond: ctx.Int("frames-per-second"),
		KeyDuration:     ctx.Duration("key-duration"),
	}

	log.Printf("-- Encoding to %s", encodeOpts.OutputPath)
	return encodeToVideo(encodeOpts, frameDir)
}

func main() {
	app := &cli.App{
		Action:      handleAnimation,
		Description: "Turn several image in an animated wallaper (for mpvpaper)",
		Flags: []cli.Flag{
			&cli.StringSliceFlag{
				Name:      "input",
				Aliases:   []string{"i"},
				Usage:     "The input files to animate",
				TakesFile: true,
			},
			&cli.StringFlag{
				Name:      "frame-dir",
				Aliases:   []string{"d"},
				Usage:     "Use an pre-existing frame directory",
				TakesFile: true,
			},
			&cli.StringFlag{
				Name:      "output",
				Aliases:   []string{"o"},
				Usage:     "Where to write the video output too",
				Required:  true,
				TakesFile: true,
			},
			&cli.IntFlag{
				Name:    "frames-per-second",
				Aliases: []string{"fps"},
				Usage:   "How many frames per second to show",
				Value:   24,
			},
			&cli.DurationFlag{
				Name:    "blend-duration",
				Aliases: []string{"b"},
				Usage:   "How long the blend animation is",
				Value:   3 * time.Second,
			},
			&cli.DurationFlag{
				Name:    "key-duration",
				Aliases: []string{"k"},
				Usage:   "How long to show each key frame",
				Value:   5 * time.Second,
			},
		},
	}

	if err := app.Run(os.Args); err != nil {
		log.Println(err)
	}
}
