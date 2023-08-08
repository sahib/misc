package main

import (
	"fmt"
	"os"

	"github.com/sahib/misc/katta/cmd"
)

func main() {
	if err := cmd.Run(os.Args); err != nil {
		fmt.Fprintf(os.Stderr, "katta: %v", err)
		os.Exit(1)
	}
}
