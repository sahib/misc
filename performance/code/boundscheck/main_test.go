package main

import (
	"testing"
)

func BenchmarkSliceAccess(b *testing.B) {
	a := [1000]int{}

	b.Run("slice", func(b *testing.B) {
		for idx := 0; idx < b.N; idx++ {
			IterateOverSlice(a[:])
		}
	})

	b.Run("range", func(b *testing.B) {
		for idx := 0; idx < b.N; idx++ {
			IterateOverSliceWithRange(a[:])
		}
	})

	b.Run("slice-with-len", func(b *testing.B) {
		for idx := 0; idx < b.N; idx++ {
			IterateOverSliceWithLen(a[:])
		}
	})
}
