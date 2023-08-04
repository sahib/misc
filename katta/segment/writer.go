package segment

import (
	"encoding/binary"
	"fmt"
	"io"

	"sync/atomic"
)

// Format:
//
// Header:
// * Magic number.
// * Version
// * Flags
//
// Block:
// * Magic number
// * Flags
// * Size in Bytes
// * Size in Elems
//
// Element:
// * Flags
// * Size
// * Data

const (
	ElemMinSize = 8
)

type Writer struct {
	headerWritten atomic.Int32
	w             io.Writer
}

func NewWriter(w io.Writer) *Writer {
	return &Writer{w: w}
}

func (w *Writer) writeHeader() error {
	_, err := w.w.Write([]byte{
		// MAGIC:
		'K', 'A', 'T', 'T', 'A', 'S', 'E', 'G',
		// VERSION:
		0x0, 0x1,
	})
	return err
}

func (w *Writer) writeEntry(flags EntryFlags, key string, val []byte) error {
	buf := make([]byte, len(key)+len(val)+1+ElemMinSize)

	// Flags:
	binary.BigEndian.PutUint32(buf[0:4], 0)

	// Size:
	binary.BigEndian.PutUint32(buf[4:8], uint32(len(key)+len(val)+1))

	// Data:
	data := buf[8:]
	copy(data, []byte(key))
	data = data[len(key):]
	data[0] = 0
	copy(data[1:], val)
	_, err := w.w.Write(buf)
	return err
}

func (w *Writer) Append(key string, val []byte) error {
	if w.headerWritten.CompareAndSwap(0, 1) {
		if err := w.writeHeader(); err != nil {
			return fmt.Errorf("write header: %w", err)
		}
	}

	var flags EntryFlags
	return w.writeEntry(flags, key, val)
}

func (w *Writer) Tombstone(key string) error {
	if w.headerWritten.CompareAndSwap(0, 1) {
		if err := w.writeHeader(); err != nil {
			return fmt.Errorf("write header: %w", err)
		}
	}

	var flags EntryFlags
	flags |= EntryFlagTombstone
	return w.writeEntry(flags, key, nil)
}
