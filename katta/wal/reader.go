package wal

import (
	"fmt"
	"io"

	"capnproto.org/go/capnp/v3"
	"github.com/sahib/misc/katta/wal/waldisk"
)

type Reader struct {
	// TODO: Make this is a io.ReadSeeker.
	r       io.Reader
	decoder *capnp.Decoder

	// iteration vars:
	err         error
	key         string
	val         []byte
	isTombstone bool
}

func NewReader(r io.Reader) *Reader {
	return &Reader{
		r:       r,
		decoder: capnp.NewPackedDecoder(r),
	}
}

func (r *Reader) Next() bool {
	msg, err := r.decoder.Decode()
	if err == io.EOF {
		// no data left in stream.
		return false
	}

	if err != nil {
		r.err = fmt.Errorf("decode: %w", err)
		return false
	}

	entry, err := waldisk.ReadRootEntry(msg)
	if err != nil {
		r.err = fmt.Errorf("read: %w", err)
		return false
	}

	r.key, _ = entry.Key()
	r.val, _ = entry.Val()
	r.isTombstone = !entry.HasVal()
	return true
}

func (r *Reader) Err() error {
	return r.err
}

func (r *Reader) Key() string {
	return r.key
}

func (r *Reader) Val() []byte {
	return r.val
}

func (r *Reader) IsTombstone() bool {
	return r.isTombstone
}

func (r *Reader) Close() error {
	c, ok := r.r.(io.Closer)
	if !ok {
		return nil
	}

	return c.Close()
}
