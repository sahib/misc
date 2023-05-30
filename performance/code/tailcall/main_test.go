package main

import "testing"

func BenchmarkSum(b *testing.B) {
	dummy := make([]int, 100)
	for idx := 0; idx < len(dummy); idx++ {
		dummy[idx] = idx
	}

	b.Run("normal", func(b *testing.B) {
		for idx := 0; idx < b.N; idx++ {
			SumNoTailcall(dummy)
		}
	})

	b.Run("tailcall", func(b *testing.B) {
		for idx := 0; idx < b.N; idx++ {
			SumTailcall(dummy)
		}
	})

	b.Run("iterative", func(b *testing.B) {
		for idx := 0; idx < b.N; idx++ {
			SumIterative(dummy)
		}
	})
}
