package main

import (
	"math/rand"
	"sort"
	"testing"
)

func BenchmarkBranchPrediction(b *testing.B) {
	const n = 32 * 1024
	data := make([]int, n)

	for idx := 0; idx < n; idx++ {
		data[idx] = rand.Intn(256)
	}

	for _, testName := range []string{"unsorted", "sorted"} {
		b.Run(testName, func(b *testing.B) {
			count := 0
			for r := 0; r < b.N; r++ {
				for idx := 0; idx < n; idx++ {
					// NOTE: Go compiler optimization disable here via flags.
					//       Go would make this a branchless operation otherwise.
					if data[idx] >= 128 {
						count += data[idx]
					}
				}
			}
		})

		sort.Ints(data)
	}
}
