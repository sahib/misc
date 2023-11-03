package main

import (
	"runtime"
	"testing"
)

func BenchmarkWordcount1(b *testing.B) {
	words := []string{
		// "the", "quick", "brown", "fox", "repeats", "the", "word", "the", "quite", "often",
		"Lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipiscing", "elit", "sed", "do", "eiusmod", "tempor", "incididunt", "ut", "labore", "et", "dolore", "magna", "aliqua", "Ut", "enim", "ad", "minim", "veniam", "quis", "nostrud", "exercitation", "ullamco", "laboris", "nisi", "ut", "aliquip", "ex", "ea", "commodo", "consequat", "Duis", "aute", "irure", "dolor", "in", "reprehenderit", "in", "voluptate", "velit", "esse", "cillum", "dolore", "eu", "fugiat", "nulla", "pariatur", "Excepteur", "sint", "occaecat", "cupidatat", "non", "proident", "sunt", "in", "culpa", "qui", "officia", "deserunt", "mollit", "anim", "id", "est", "laborum",
	}

	b.Run("noptr", func(b *testing.B) {
		for idx := 0; idx < b.N; idx++ {
			wordcount(words)
		}
		runtime.GC()
	})

	runtime.GC()

	b.Run("ptr", func(b *testing.B) {
		for idx := 0; idx < b.N; idx++ {
			wordcountPtr(words)
		}
		runtime.GC()
	})
}
