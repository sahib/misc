package main

import (
	"fmt"
	"time"
)

func main() {
	now := time.Now()
	fmt.Println("BEFORE", now)
	// time.Sleep(time.Minute)
	fmt.Println("AFTER", now)
	fmt.Println(time.Since(now))

	tick := time.Now()
	for {
		time.Sleep(time.Second)
		fmt.Println(time.Since(tick), time.Now())
	}
}
