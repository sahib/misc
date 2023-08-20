package wal

import (
	"io"

	"capnproto.org/go/capnp/v3"
	"github.com/sahib/misc/katta/wal/waldisk"
)

type Writer struct {
	ws      io.Writer
	encoder *capnp.Encoder
	arena   []byte
}

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

	entry.SetKey(key)
	entry.SetVal(val)
	return w.encoder.Encode(msg)
}

func (w *Writer) Append(key string, val []byte) error {
	return w.writeEntry(key, val)
}

func (w *Writer) Pos() int64 {
	// TODO: That's a sucky way to tell the current position
	// as it involves doing an additionaly syscall all the time.
	// There must be a better way!
	seeker := w.ws.(io.Seeker)
	off, _ := seeker.Seek(0, io.SeekCurrent)
	return off
}
