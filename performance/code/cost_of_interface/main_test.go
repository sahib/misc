package main

import (
	"io"
	"testing"
)

// Shamelessly stolen from here:
// https://syslog.ravelin.com/go-interfaces-but-at-what-cost-961e0f58a07b

type zeroReader struct{}

func (z zeroReader) Read(p []byte) (n int, err error) {
	for i := range p {
		p[i] = 0
	}
	return len(p), nil
}

func BenchmarkInterfaceAlloc(b *testing.B) {
	var z zeroReader
	var r io.Reader
	r = z
	b.Run("via interface", func(b *testing.B) {
		b.ReportAllocs()
		for i := 0; i < b.N; i++ {
			var buf [7]byte
			r.Read(buf[:])
		}
	})

	b.Run("direct", func(b *testing.B) {
		b.ReportAllocs()
		for i := 0; i < b.N; i++ {
			// compiler can inline Read() here
			// AND also figure out that `buf` does not escape to the heap.
			var buf [7]byte
			z.Read(buf[:])
		}
	})
}
