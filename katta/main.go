package main

import (
	"os"

	"github.com/sahib/misc/katta/kv"
)

func main() {
	s, err := kv.Open(os.Args[1], kv.DefaultOptions())
	if err != nil {
		panic(err)
	}

	s.Set("key", []byte("value"))
}
