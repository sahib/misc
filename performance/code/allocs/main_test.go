package main

import (
	"testing"
)

func BenchmarkWordcount1(b *testing.B) {
	words := []string{
		"the", "quick", "brown", "fox", "repeats", "the", "word", "the", "quite", "often",
	}

	b.Run("noptr", func(b *testing.B) {
		for idx := 0; idx < b.N; idx++ {
			wordcount(words)
		}
	})
	b.Run("ptr", func(b *testing.B) {
		for idx := 0; idx < b.N; idx++ {
			wordcountPtr(words)
		}
	})
}
