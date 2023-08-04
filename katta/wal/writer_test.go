package wal

import (
	"bufio"
	"bytes"
	"fmt"
	"testing"
)

func TestWriterHappycase(t *testing.T) {
	buf := &bytes.Buffer{}
	w := NewWriter(buf)

	w.Append("key1", []byte("value1"))
	w.Append("key2", []byte("value2"))
	w.Append("key3", []byte("value3"))
	w.AppendTombstone("key4")

	r := NewReader(bufio.NewReader(buf))
	for r.Next() {
		key := r.Key()
		val := r.Val()
		fmt.Printf("%s=%s\n", key, string(val))
	}

	fmt.Println(r.Err())
}

func BenchmarkWALWrite(b *testing.B) {
	buf := &bytes.Buffer{}

	w := NewWriter(buf)
	dummyValue := make([]byte, 1024)
	for idx := 0; idx < b.N; idx++ {
		b.StartTimer()
		for idx := 0; idx < 100; idx++ {
			w.Append("regular_sized_key", dummyValue)
		}

		w.AppendTombstone("regular_sized_key")
		b.StopTimer()

		buf.Reset()
	}
}
