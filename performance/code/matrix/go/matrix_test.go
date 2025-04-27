package main

import "testing"

const X, Y = 2000, 2000

func sumRow(m [][]int) int {
	sum := 0
	for y := 0; y < Y; y++ {
		for x := 0; x < X; x++ {
			if x != y {
				sum += m[y][x]
			}
		}
	}

	return sum
}

func sumCol(m [][]int) int {
	sum := 0
	for x := 0; x < X; x++ {
		for y := 0; y < Y; y++ {
			if x != y {
				sum += m[x][y]
			}
		}
	}

	return sum
}

func M() [][]int {
	m := make([][]int, Y)
	for y := 0; y < Y; y++ {
		m[y] = make([]int, X)
		for x := 0; x < 0; x++ {
			m[y][x] = x * y
		}
	}

	return m
}

func BenchmarkSumRow(b *testing.B) {
	m := M()
	b.ResetTimer()
	for n := 0; n < b.N; n++ {
		sumRow(m)
	}
}

func BenchmarkSumCol(b *testing.B) {
	m := M()
	b.ResetTimer()
	for n := 0; n < b.N; n++ {
		sumCol(m)
	}
}
