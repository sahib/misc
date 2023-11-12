package main

import (
	"runtime"
	"testing"
)

func BenchmarkItem(b *testing.B) {
	var items Items
	for idx := 0; idx < 1000; idx++ {
		items = append(items, Item{
			Key:  int64(idx),
			Blob: []byte("Lorem ipsum dolor sit"),
		})
	}

	for i := 0; i < b.N; i++ {
		items.Copy()
		runtime.GC()
	}

}

func BenchmarkItemPrealloc(b *testing.B) {
	var items Items
	for idx := 0; idx < 1000; idx++ {
		items = append(items, Item{
			Key:  int64(idx),
			Blob: []byte("Lorem ipsum dolor sit"),
		})
	}

	for i := 0; i < b.N; i++ {
		items.CopyPrealloc()
		runtime.GC()
	}
}

func BenchmarkItemOptimized(b *testing.B) {
	var items Items
	for idx := 0; idx < 1000; idx++ {
		items = append(items, Item{
			Key:  int64(idx),
			Blob: []byte("Lorem ipsum dolor sit"),
		})
	}

	for i := 0; i < b.N; i++ {
		items.CopyOptimized()
		runtime.GC()
	}
}
