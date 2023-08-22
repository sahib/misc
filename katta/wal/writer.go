package wal

import (
	"io"

	"capnproto.org/go/capnp/v3"
	"github.com/sahib/misc/katta/wal/waldisk"
)

// XXX: We use Cap'n'Proto, not because it's the fastest or most compact
//      alternative, but it's impelemented very fast and quite easy.
//      Can you imagine how you would design your own binary representation
//      of a WAL? What if you need to support compression or data integrity
//      features like checksums (or even encryption)?

// Writer helps writing a write ahead log.
type Writer struct {
	ws      io.Writer
	encoder *capnp.Encoder
	arena   []byte
}

// NewWriter wraps `ws` as a WAL Writer.
// `ws` should support io.Seeker if Pos() is used.
func NewWriter(ws io.Writer) *Writer {
	encoder := capnp.NewEncoder(ws)
	return &Writer{
		ws:      ws,
		encoder: encoder,
		arena:   make([]byte, 4096),
	}
}

func (w *Writer) writeEntry(key string, val []byte) error {
	msg, seg := capnp.NewSingleSegmentMessage(w.arena[:0])
	entry, err := waldisk.NewRootEntry(seg)
	if err != nil {
		return err
	}

	if err := entry.SetKey(key); err != nil {
		return err
	}

	if err := entry.SetVal(val); err != nil {
		return err
	}

	return w.encoder.Encode(msg)
}

// Append a new entry to the WAL.
// It is not synced directly.
//
// XXX: What happens if we set a few keys and crash the database?
//
//	Can we do against loosing keys here?
func (w *Writer) Append(key string, val []byte) error {
	return w.writeEntry(key, val)
}

// Pos returns the current position (i.e. max written offset)
//
// XXX: Can we be clever here and not require io.Seeker?
//
//	Seek() is an expensive syscall.
func (w *Writer) Pos() int64 {
	seeker := w.ws.(io.Seeker)
	off, _ := seeker.Seek(0, io.SeekCurrent)
	return off
}
