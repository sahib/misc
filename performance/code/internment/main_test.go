package main

import (
	"strings"
	"testing"
)

func benchmarkStringCompare(b *testing.B, count int) {
	s1 := strings.Repeat("a", count)
	s2 := strings.Repeat("a", count)
	//b.ResetTimer()
	for n := 0; n < b.N; n++ {
		if s1 != s2 {
			b.Fatal()
		}
	}
}

func benchmarkStringCompareIntern(b *testing.B, count int) {
	si := stringInterner{}
	s1 := si.Intern(strings.Repeat("a", count))
	s2 := si.Intern(strings.Repeat("a", count))
	// b.ResetTimer()
	for n := 0; n < b.N; n++ {
		if s1 != s2 {
			b.Fatal()
		}
	}
}

func BenchmarkStringCompare1(b *testing.B)   { benchmarkStringCompare(b, 1) }
func BenchmarkStringCompare10(b *testing.B)  { benchmarkStringCompare(b, 10) }
func BenchmarkStringCompare100(b *testing.B) { benchmarkStringCompare(b, 100) }

func BenchmarkStringCompareIntern1(b *testing.B)   { benchmarkStringCompareIntern(b, 1) }
func BenchmarkStringCompareIntern10(b *testing.B)  { benchmarkStringCompareIntern(b, 10) }
func BenchmarkStringCompareIntern100(b *testing.B) { benchmarkStringCompareIntern(b, 100) }
