package main

import (
	"log"
	"os"
	"time"

	"github.com/stianeikeland/go-rpio/v4"
)

const (
	beeperPin = rpio.Pin(27)
	buttonPin = rpio.Pin(17)
	micro     = 50 * time.Millisecond

	short = 150 * time.Millisecond
	long  = 3 * short
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
		} else if chr == '-' {
			peep(pin, long)
		} else {
			log.Printf("bad morse glyph: %v", chr)
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

	beeperPin.Mode(rpio.Output)
	buttonPin.Mode(rpio.Input)

	// startup peep:
	for idx := 0; idx < 3; idx++ {
		peep(beeperPin, micro)
		time.Sleep(micro)
	}

	curr := 0
	for {
		if buttonPin.Read() != rpio.High {
			time.Sleep(20 * time.Millisecond)
			continue
		}

		time.Sleep(micro)
		log.Printf("do peep: %s", morses[curr%len(morses)])
		peepMorse(beeperPin, morses[curr%len(morses)])
		time.Sleep(long)
		curr++
	}

}
