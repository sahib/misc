package wal

import (
	"bytes"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestWriterHappycase(t *testing.T) {
	buf := &bytes.Buffer{}
	w := NewWriter(buf)

	w.Append("key1", []byte("value1"))
	w.Append("key2", []byte("value2"))
	w.Append("key3", []byte("value3"))
	w.Append("key4", nil)

	r := NewReader(bytes.NewReader(buf.Bytes()))
	var entry Entry
	var idx int
	for r.Next(&entry) {
		switch idx {
		case 0:
			require.Equal(t, "key1", entry.Key)
			require.Equal(t, []byte("value1"), entry.Val)
			require.False(t, entry.IsTombstone)
		case 1:
			require.Equal(t, "key2", entry.Key)
			require.Equal(t, []byte("value2"), entry.Val)
			require.False(t, entry.IsTombstone)
		case 2:
			require.Equal(t, "key3", entry.Key)
			require.Equal(t, []byte("value3"), entry.Val)
			require.False(t, entry.IsTombstone)
		case 3:
			require.Equal(t, "key4", entry.Key)
			require.Nil(t, entry.Val)
			require.True(t, entry.IsTombstone)
		default:
			t.Errorf("invalid index reached: %v", idx)
			t.FailNow()
		}

		idx++
	}

	require.NoError(t, r.Err())
}

func TestReaderEmpty(t *testing.T) {
	buf := &bytes.Buffer{}
	r := NewReader(bytes.NewReader(buf.Bytes()))

	var entry Entry
	require.False(t, r.Next(&entry))
	require.NoError(t, r.Err())
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

		w.Append("tombstone", nil)
		b.StopTimer()

		buf.Reset()
	}
}
