package main

import (
	"fmt"
	"os"
	"os/signal"
	"runtime"
	"runtime/trace"
	"sync"
	"sync/atomic"
	"syscall"
	"time"
)

type Counter interface {
	StartAdding(n int)
	Count() int64
}

////////////////////

type Counter1 struct {
	mu    sync.Mutex
	count int64
}

func (c *Counter1) StartAdding(n int) {
	for {
		c.mu.Lock()
		c.count++
		c.mu.Unlock()
	}
}

func (c *Counter1) Count() int64 {
	c.mu.Lock()
	defer c.mu.Unlock()
	return c.count
}

////////////////////

type Counter2 struct {
	count int64
}

func (c *Counter2) StartAdding(n int) {
	for {
		atomic.AddInt64(&c.count, 1)
	}
}

func (c *Counter2) Count() int64 {
	return atomic.LoadInt64(&c.count)
}

////////////////////

type Counter3 struct {
	x      int
	counts [8]int64
}

func (c *Counter3) StartAdding(n int) {
	for {
		c.counts[n]++
	}
}

func (c *Counter3) Count() int64 {
	var sum int64
	for _, part := range c.counts {
		sum += part
	}

	return sum
}

////////////////////

type paddedCounter struct {
	Count int64
	_     [64]byte
}

type Counter4 struct {
	counts [8]paddedCounter
}

func (c *Counter4) StartAdding(n int) {
	for {
		c.counts[n].Count++
	}
}

func (c *Counter4) Count() int64 {
	var sum int64
	for _, part := range c.counts {
		sum += part.Count
	}

	return sum
}

////////////////////

const traceIt = false

func main() {
	if traceIt {
		fd, err := os.Create("/tmp/counter.trace")
		if err != nil {
			panic(err)
		}

		sigs := make(chan os.Signal, 1)
		signal.Notify(sigs, syscall.SIGINT)

		trace.Start(fd)
		defer trace.Stop()
	}

	var counters = map[string]Counter{
		"mutex":       &Counter1{},
		"atomic":      &Counter2{},
		"strided":     &Counter3{},
		"strided-pad": &Counter4{},
	}

	name := os.Args[1]
	counter, ok := counters[name]
	if !ok {
		fmt.Println("Invalid name", name)
		return
	}

	for n := 0; n < runtime.GOMAXPROCS(0)*2; n++ {
		go counter.StartAdding(n)
	}

	time.Sleep(10 * time.Second)
	fmt.Println(counter.Count() / 10.0)
}
