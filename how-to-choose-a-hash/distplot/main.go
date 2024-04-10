package main

import (
	"bufio"
	"bytes"
	"crypto/md5"
	"crypto/rand"
	_ "embed"
	"encoding/binary"
	"fmt"
	"hash/crc32"
	"hash/maphash"
	"image"
	"image/color"
	"image/png"
	"os"

	"github.com/redbo/gohsv"
	"github.com/spaolacci/murmur3"
	"golang.org/x/crypto/sha3"
)

// The file below was generated with the following command:
// seq 0 50000000 > nums.txt

var (
	//go:embed nums.txt
	wordsTxt []byte
)

const (
	Width  = 1024
	Height = 1024
)

func readEnglishWords() ([]string, error) {
	words := make([]string, 0, 466550)
	scanner := bufio.NewScanner(bytes.NewReader(wordsTxt))
	for scanner.Scan() {
		words = append(words, scanner.Text())
	}

	if err := scanner.Err(); err != nil {
		return nil, err
	}

	return words, nil
}

func hashRandom(_ string) uint64 {
	var buf [8]byte
	rand.Read(buf[:])
	return binary.BigEndian.Uint64(buf[:])
}

func hashCrossTotal(w string) uint64 {
	h := uint64(0)
	for _, c := range w {
		h += h + uint64(c)
	}

	return h
}

func hashFibonacci(w string) uint64 {
	const fib = 11400714819323198485
	h := uint64(len(w))
	for _, c := range w {
		h = h*fib + uint64(c)
	}

	return h
}

func hashSha3(w string) uint64 {
	h := sha3.Sum224([]byte(w))
	return binary.BigEndian.Uint64(h[:])
}

func hashMd5(w string) uint64 {
	h := md5.Sum([]byte(w))
	return binary.BigEndian.Uint64(h[:])
}

func hashMurmur3(w string) uint64 {
	return murmur3.Sum64([]byte(w))
}

var (
	maphashSeed = maphash.MakeSeed()
)

func hashMaphash(w string) uint64 {
	return maphash.String(maphashSeed, w)
}

func hashFNV1a(w string) uint64 {
	const (
		prime  = uint64(16777619)
		offset = uint64(2166136261)
		modVal = ((1 << 32) - 1)
	)

	hash := uint64(offset)
	for _, v := range w {
		hash ^= uint64(v)
		hash = (hash * uint64(prime)) % modVal
	}

	return uint64(hash)
}

var (
	castagnoliCrc32Table = crc32.MakeTable(crc32.Castagnoli)
)

func hashCRC32(w string) uint64 {
	h1 := crc32.Checksum([]byte(w), castagnoliCrc32Table)
	h2 := crc32.ChecksumIEEE([]byte(w))
	return uint64(h1)<<32 | uint64(h2)
}

func distplot(imageName string, hash func(w string) uint64) error {
	words, err := readEnglishWords()
	if err != nil {
		return err
	}

	img := make([][]uint32, Height)
	for x := range Height {
		img[x] = make([]uint32, Width)
	}

	// used to find out the value range, used to normalize later.
	var maxHits uint32
	var collisions uint32

	for _, word := range words {
		h := hash(word)

		// clamp range to image size:
		h %= Width * Height
		// fmt.Println(h)

		x, y := int(h/Width), int(h%Width)
		img[x][y]++
		if v := img[x][y]; v > maxHits {
			maxHits = v
		}

		if v := img[x][y]; v > 1 {
			collisions++
		}
	}

	// convert to PNG:
	rgbImage := image.NewRGBA(image.Rectangle{
		Min: image.Point{
			X: 0,
			Y: 0,
		},
		Max: image.Point{
			X: Width,
			Y: Height,
		},
	})

	for x := range img {
		for y := range img[x] {
			v := float64(img[x][y]) / float64(maxHits)
			r, g, b := gohsv.HSVtoRGB(360*(float64(y)/Width), 0.7, v)
			rgbImage.Set(x, y, color.RGBA{
				R: uint8(float64(r) / 0xff),
				G: uint8(float64(g) / 0xff),
				B: uint8(float64(b) / 0xff),
				A: 255,
			})
		}
	}

	fd, err := os.OpenFile(imageName, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0600)
	if err != nil {
		return err
	}

	fmt.Printf("max collisions for %s: %d (%.2f%% collisions)\n", imageName, maxHits, 100*float64(collisions)/float64(len(words)))
	defer fd.Close()
	return png.Encode(fd, rgbImage)
}

func main() {
	plots := []struct {
		Name string
		Hash func(w string) uint64
	}{
		{
			Name: "image_random.png",
			Hash: hashRandom,
		},
		{
			Name: "image_crosstotal.png",
			Hash: hashCrossTotal,
		},
		{
			Name: "image_md5.png",
			Hash: hashMd5,
		},
		{
			Name: "image_sha3.png",
			Hash: hashSha3,
		},
		{
			Name: "image_fnv1a.png",
			Hash: hashFNV1a,
		},
		{
			Name: "image_crc32.png",
			Hash: hashCRC32,
		},
		{
			Name: "image_murmur3.png",
			Hash: hashMurmur3,
		},
		{
			Name: "image_maphash.png",
			Hash: hashMaphash,
		},
		{
			Name: "image_fibonacci.png",
			Hash: hashFibonacci,
		},
	}

	for _, plot := range plots {
		if err := distplot(plot.Name, plot.Hash); err != nil {
			fmt.Printf("failed: %s\n", err)
			os.Exit(1)
		}
	}
}
