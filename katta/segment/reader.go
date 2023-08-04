package segment

import (
	"fmt"
	"sync/atomic"
)

type Reader struct {
	m            []byte
	size         uint64
	headerParsed atomic.Bool

	err error
}

func (r *Reader) ID() ID {
	return 0
}

func (r *Reader) parseHeader() error {
	return nil
}

func (r *Reader) Next() bool {
	if r.headerParsed.CompareAndSwap(false, true) {
		if err := r.parseHeader(); err != nil {
			r.err = fmt.Errorf("header: %w", err)
			return false
		}
	}

	return false
}

func (r *Reader) Seek(off Off) error {
	return nil
}

func (r *Reader) Pos() Off {
	return 0
}

func (r *Reader) Key() string {
	return ""
}

// Value returns the current value.
// The second bool return is true if this is a tombstone
// and which case the value does not exist.
func (r *Reader) Value() ([]byte, bool) {
	return nil, false
}

func (r *Reader) Off() Off {
	return 0
}

func (r *Reader) Err() error {
	return r.err
}
