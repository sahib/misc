package wal

import (
	"fmt"
	"io"

	"capnproto.org/go/capnp/v3"
	"github.com/sahib/misc/katta/wal/waldisk"
)

// TODO: This reader can likely be made much more efficient using mmap!

type Entry struct {
	Pos         int64
	Key         string
	Val         []byte
	IsTombstone bool
}

type Reader struct {
	r       io.ReadSeeker
	decoder *capnp.Decoder
	err     error
}

func NewReader(r io.ReadSeeker) *Reader {
	return &Reader{
		r:       r,
		decoder: capnp.NewDecoder(r),
	}
}

func (r *Reader) Pos() (int64, error) {
	// TODO: Possibly optimize with an index that is
	//       incremented on every Read/Seek. This would
	//       avoid a lot of syscalls!
	// TODO: returning an error here is not nice.
	return r.r.Seek(0, io.SeekCurrent)
}

func (r *Reader) Seek(offset int64, whence int) (int64, error) {
	return r.r.Seek(offset, whence)
}

func (r *Reader) Next(e *Entry) bool {
	// position needs to be determined before reading
	e.Pos, _ = r.Pos()

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

	e.Key, _ = entry.Key()
	e.Val, _ = entry.Val()
	e.IsTombstone = !entry.HasVal()

	return true
}

func (r *Reader) Err() error {
	return r.err
}

func (r *Reader) Close() error {
	c, ok := r.r.(io.Closer)
	if !ok {
		return nil
	}

	return c.Close()
}
