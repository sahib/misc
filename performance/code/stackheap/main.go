package main

import (
	"fmt"
	"strconv"
	"unsafe"
)

//go:noinline
func f() *int {
	v := 3
	return &v
}

func main() {
	// Two for the stack:
	a := 23
	b := 42

	// Two for the heap:
	var c *int = f()
	var d *int = f()

	// For unclear reasons everything that goes to fmt.Println() is allocated on the heap.
	// Likely because Println() stores some reference on it in some struct internally.
	// See here for more info: https://github.com/golang/go/issues/19720
	//
	// We workaround in this example by converting the values before hand,
	// sadly this requires a little pointer fiddling which we won't explain here.
	// You can check if this works by compiling this program like so:
	//
	// $ go build -gcflags="-m" .
	//
	// (a and b should not escape to heap in this example)
	sa := strconv.FormatInt(int64(uintptr(unsafe.Pointer(&a))), 16)
	sb := strconv.FormatInt(int64(uintptr(unsafe.Pointer(&b))), 16)
	sc := strconv.FormatInt(int64(uintptr(unsafe.Pointer(c))), 16)
	sd := strconv.FormatInt(int64(uintptr(unsafe.Pointer(d))), 16)
	fmt.Println(sa, sb)
	fmt.Println(sc, sd)
}
