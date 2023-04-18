package main

import "fmt"

// Small example of BCE - Bound Check Elimination.
// The Go compiler will normally check if an index is out of bounds
// when accessing for a slice. This is a very good safety feature,
// but it comes with the small cost of checking lower and upper bounds.
//
// The Go compiler is normally pretty clever when it comes to figuring out
// when to insert a bounds check. If an index is used twice e.g. it will
// only bound check the first one and assume the second access is safe.
//
// This small test program contains a simple sum benchmark with different loops.
// On my machine the results look like this:
// BenchmarkSliceAccess/slice-4          511.2 ns/op
// BenchmarkSliceAccess/range-4          463.6 ns/op
// BenchmarkSliceAccess/slice-with-len-4 426.9 ns/op
//
// As you can see, in the first function below the compiler does
// not know how if `idx` can exceed the size of the slice - since
// we're just using a constant here and the actual slice length
// is determined at runtime.
//
// In the other cases the compiler can figure it out. The for loop
// goes until the length of slice and no further. Same with the range
// loop (which is a little slower since it needs to do a bit more copying).
//
// You can ask the compiler where it needs to do bounds checking:
// $ go run -gcflags="-d=ssa/check_bce" main.go
// ./main.go:9:14: Found IsInBounds

//go:noinline
func IterateOverSlice(ints []int) int {
	sum := 0
	for idx := 0; idx < 1000; idx++ {
		sum += ints[idx] // bounds check needed here!
	}

	return sum
}

//go:noinline
func IterateOverSliceWithLen(ints []int) int {
	sum := 0
	for idx := 0; idx < len(ints); idx++ {
		sum += ints[idx]
	}

	return sum
}

//go:noinline
func IterateOverSliceWithRange(ints []int) int {
	sum := 0
	for _, val := range ints {
		sum += val
	}

	return sum
}

func main() {
	a := make([]int, 1000)
	for idx := range a {
		a[idx] = idx
	}

	fmt.Println(IterateOverSlice(a))
	fmt.Println(IterateOverSliceWithLen(a))
	fmt.Println(IterateOverSliceWithRange(a))
}
