package wal

import (
	"fmt"
	"io"

	"capnproto.org/go/capnp/v3"
	"github.com/sahib/misc/katta/wal/waldisk"
)

// XXX: This reader uses slow file I/O, which has some overhead
//      since we have to call Seek() quite often. Also we cannot
//      do any buffering, because we need to know the exact position
//      of each entry (and buffering would spoil that)
//
//      A great alternative would be to use mmap() on the file
//      and rewrite the API below to use that. Make sure to benchmark!
//
// You might find some inspiration here:
// https://github.com/sahib/timeq/blob/main/vlog/vlog.go#L69

// Entry is one entry in a write ahead log.
type Entry struct {
	Pos         int64
	Key         string
	Val         []byte
	IsTombstone bool
}

// Reader helps loading write a head logs.
type Reader struct {
	io.Seeker
	r       io.ReadSeeker
	decoder *capnp.Decoder
	err     error
}

// NewReader returns a new reader
// You should call Next() in a for loop
// and check Err() afterwards.
func NewReader(r io.ReadSeeker) *Reader {
	return &Reader{
		r:       r,
		decoder: capnp.NewDecoder(r),
		Seeker:  r,
	}
}

// Pos returns the current position in the stream.
func (r *Reader) Pos() (int64, error) {
	return r.r.Seek(0, io.SeekCurrent)
}

// Next returns the next entry in the stream (returns true)
// or stops if there are no more entries (returns false)
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

// Err returns the latest error or nil if all succeeded
func (r *Reader) Err() error {
	return r.err
}

// Close tries to close the reader if it is closable.
func (r *Reader) Close() error {
	c, ok := r.r.(io.Closer)
	if !ok {
		return nil
	}

	return c.Close()
}
