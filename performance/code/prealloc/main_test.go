package main

import "testing"

const NAppends = 1000

// This tiny benchmark measures the performance of appending
// to a slice that is pre-allocated and one that is empty at start.
// Go will grow the slice depending on the needs by doubling
// its capacity once a new element would overflow the underlying array.
//
// Once the array grows Go has to copy the slice contents to the new
// location, costing not only allocations costs but also time.
// Since this happens frequently for small slices this can take
// up quite some time:
//
// BenchmarkAppendNoPreAlloc-4    6425 ns/op  25208 B/op  12 allocs/op
// BenchmarkAppendWithPreAlloc-4   711 ns/op      0 B/op   0 allocs/op

func BenchmarkAppendNoPreAlloc(b *testing.B) {
	for n := 0; n < b.N; n++ {
		s := make([]int, 0)
		for idx := 0; idx < NAppends; idx++ {
			s = append(s, idx)
		}
	}
}

func BenchmarkAppendWithPreAlloc(b *testing.B) {
	for n := 0; n < b.N; n++ {
		s := make([]int, 0, NAppends)
		for idx := 0; idx < NAppends; idx++ {
			s = append(s, idx)
		}
	}
}
