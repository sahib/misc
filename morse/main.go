package main

import (
	"log"
	"os"
	"time"

	"github.com/stianeikeland/go-rpio/v4"
)

const (
	beeperPin = 2
	short     = 250 * time.Millisecond
	long      = 3 * short
)

func peep(pin rpio.Pin, d time.Duration) {
	pin.High()
	time.Sleep(d)
	pin.Low()
}

func peepMorse(pin rpio.Pin, morse string) {
	for _, chr := range morse {
		if chr == '.' {
			peep(pin, short)
		} else if chr == '_' {
			peep(pin, long)
		}

		time.Sleep(short)
	}
}

func main() {
	if len(os.Args) == 1 {
		log.Printf("usage: %s [words]", os.Args[0])
		return
	}

	morses := encode(os.Args[1])
	if err := rpio.Open(); err != nil {
		log.Fatalf("failed to init gpio: %v", err)
	}

	defer rpio.Close()

	pin := rpio.Pin(beeperPin)
	pin.Mode(rpio.Output)

	// startup peep:
	peep(pin, short)

	for {
		for _, morse := range morses {
			peepMorse(pin, morse)
			time.Sleep(long)
		}
	}

}
