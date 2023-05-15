package main

import (
	"bytes"
	"testing"
)

var (
	dummyData = []byte("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque molestie.")
)

func BenchmarkWriteGzipWithPool(b *testing.B) {
	for n := 0; n < b.N; n++ {
		compressWithPool(bytes.NewReader(dummyData))
	}
}

func BenchmarkWriteGzipWithoutPool(b *testing.B) {
	for n := 0; n < b.N; n++ {
		compressWithoutPool(bytes.NewReader(dummyData))
	}
}

func BenchmarkParallelWriteGzipWithPool(b *testing.B) {
	b.RunParallel(func(pb *testing.PB) {
		for pb.Next() {
			compressWithPool(bytes.NewReader(dummyData))
		}
	})
}
func BenchmarkParallelWriteGzipWithoutPool(b *testing.B) {
	b.RunParallel(func(pb *testing.PB) {
		for pb.Next() {
			compressWithoutPool(bytes.NewReader(dummyData))
		}
	})
}
