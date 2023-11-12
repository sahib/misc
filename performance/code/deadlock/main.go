package main

import (
	"time"
)

func main() {
	// Comment out this line to see Go complain about a deadlock situation:
	go func() { time.Sleep(100 * time.Hour) }()

	// Use Ctrl+\ to get a stack trace:
	ch := make(chan int)
	<-ch

	// You can also use delve to check where the go routines are:
	// dlv attach $(pgrep deadlock) ./deadlock
	// > goroutines -t
}
