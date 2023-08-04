package wal

import (
	"io"

	"capnproto.org/go/capnp/v3"
	"github.com/sahib/misc/katta/wal/waldisk"
)

type Writer struct {
	w       io.Writer
	encoder *capnp.Encoder
	arena   []byte
}

func NewWriter(w io.Writer) *Writer {
	encoder := capnp.NewPackedEncoder(w)
	return &Writer{
		w:       w,
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

	entry.SetKey(key)
	entry.SetVal(val)
	return w.encoder.Encode(msg)
}

func (w *Writer) Append(key string, val []byte) error {
	return w.writeEntry(key, val)
}

func (w *Writer) AppendTombstone(key string) error {
	return w.writeEntry(key, nil)
}
