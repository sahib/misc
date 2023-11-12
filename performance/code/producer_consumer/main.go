package main

import (
	"context"
	"fmt"
	"os"
	"runtime/trace"
	"strconv"
	"sync"
	"time"
)

type Result struct {
	In   int
	Out  int
	Took time.Duration
}

func calculation(v int) int {
	v = 10000*v + v
	for i := 0; i < 1e4; i++ {
		// just burn some cpu cycles.
		for idx := 0; idx < v; idx++ {
		}

		v++
	}

	return v
}

func worker(ctx context.Context, inCh <-chan int, outCh chan<- Result) {
	for {
		select {
		case <-ctx.Done():
			return
		case in := <-inCh:
			now := time.Now()
			out := calculation(in)
			outCh <- Result{
				In:   in,
				Out:  out,
				Took: time.Since(now),
			}
		}
	}
}

func main() {
	// Parse program parameters:
	if len(os.Args) < 3 {
		fmt.Printf("usage: %s [nworkers] [njobs]\n", os.Args[0])
		return
	}

	nworkers, err := strconv.Atoi(os.Args[1])
	if err != nil {
		fmt.Printf("bad nworkers: %v\n", os.Args[1])
		return
	}

	njobs, err := strconv.Atoi(os.Args[2])
	if err != nil {
		fmt.Printf("bad njobs: %v\n", os.Args[2])
		return
	}

	// Start tracing:
	fd, err := os.Create("trace.out")
	if err != nil {
		fmt.Printf("cannot open trace file: %v\n", err)
		return
	}

	defer fd.Close()

	trace.Start(fd)
	defer trace.Stop()

	inCh := make(chan int, njobs)
	outCh := make(chan Result, njobs)
	wg := sync.WaitGroup{}

	// Terminate after max. 100s:
	ctx, cancel := context.WithTimeout(context.Background(), 100*time.Second)

	// Start workers:
	for idx := 0; idx < nworkers; idx++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			worker(ctx, inCh, outCh)
		}()
	}

	// Send jobs to workers:
	for idx := 0; idx < njobs; idx++ {
		inCh <- idx
	}

	// Why does it make a difference if we use this for loop?
	// for idx := 0; idx < njobs; idx++ {

	// Fetch results:
	for idx := njobs; idx > 0; idx-- {
		select {
		case result := <-outCh:
			fmt.Printf("%d -> %d (%v)\n", result.In, result.Out, result.Took)
		}
	}

	// wait for go-routines to finish:
	cancel()
	wg.Wait()
}
