package main

import (
	"encoding/binary"
	"fmt"
)

var depth uint64

func recursive() {
	depth++

	// allocate 1MB of data on the stack
	// (we can check via -gcflags="-m" if it's really on the stack)
	// work around the "variable not used"-error by writing
	// the depth counter to the start of b so it gets used.
	var b [1024 * 1024]byte

	binary.BigEndian.PutUint64(b[:], depth)
	mbs := binary.BigEndian.Uint64(b[:])

	fmt.Printf("%.2f MB of stack used\n", float64(mbs))
	recursive()
}

// Crashes on my machine at:
// 478.48 MB.
//
// Theoretical limit for Go:
// 1000000000-byte ~= 980 MB.
//
// fmt.Printf() gets inlined and adds quite a bit
// to the stack space.

func main() {
	recursive()
}
