package segment

import (
	"fmt"
	"io"

	"capnproto.org/go/capnp/v3"
	"github.com/sahib/misc/katta/segment/indexdisk"
	"github.com/tidwall/btree"
	"golang.org/x/exp/constraints"
)

const (
	maxElements = 500
)

type Off int32

// Index maps keys to offsets. It is supposed to be created for each segment.
// The index expects that all keys are feed to the index. The implementation
// is sparse, i.e. not all keys are stored in-memory, but only a small fraction
// of them. The Lookup function will return a range therefore.
type Index struct {
	tree        *btree.Map[string, Off]
	maxElements int
	maxKnown    Off
	minKnown    Off
}

// TODO: Implement bloom filter to quickly check if a key is present.
//       Currently we scan through all segments even if a key is not
//       in any of them. This can be mitigated by having a bloom filter
//       that remembers those cases and is consulted before a Get.

// New returns an empty index.
func NewIndex() *Index {
	return &Index{
		tree:        &btree.Map[string, Off]{},
		maxElements: maxElements,
	}
}

func min[T constraints.Ordered](a, b T) T {
	if a < b {
		return a
	}

	return b
}

func max[T constraints.Ordered](a, b T) T {
	if a < b {
		return b
	}

	return a
}

func (i *Index) Set(key string, off Off) {
	i.tree.Set(key, off)

	i.minKnown = min(off, i.minKnown)
	i.maxKnown = max(off, i.maxKnown)
}

func (i *Index) Delete(key string) {
	i.tree.Delete(key)
}

// Lookup checks the index for the position of `key`.
// The return values are offsets that indicate in what range the
// result will be. The index can only reason about
//
//  1. Both results are different.
//     The result is somewhere in between (excluding both)
//  2. Both results are the same.
//     The result is exactly at this position
//     and can directly be fetched.
func (i *Index) Lookup(key string) (Off, Off) {
	iter := i.tree.Iter()

	var lo Off
	var hi Off

	// Seeks to greater-or-equal than `key`.
	if iter.Seek(key) {
		// We have a value greater-or-equal than key.
		// Since our index is sparse, we cannot guarantee this happens.
		// In this case we leave the value as nil to indicate to caller
		// that he has to search until the end.
		hi = iter.Value()

		// special case: we have this exact key in the index.
		// In this case we do not need to look further.
		if iter.Key() == key {
			return hi, hi
		}
	} else {
		hi = i.maxKnown
	}

	if iter.Prev() {
		// We have the closest value < `key`. Same edge case
		// as above applies, as this might not happen
		lo = iter.Value()
	} else {
		lo = i.minKnown
	}

	return lo, hi
}

func (i *Index) sparsify() {
	l := i.tree.Len()
	if l < i.maxElements {
		return
	}

	getRidOffTotal := l - i.maxElements
	getRidOneEvery := float64(l) / float64(getRidOffTotal)
	one := 1.0 / float64(l)

	count := 0.0
	i.tree.ScanMut(func(key string, val Off) bool {
		count += one
		if count >= getRidOneEvery {
			i.tree.Delete(key)
		}

		return true
	})
}

func (i *Index) Marshal(w io.Writer) error {
	encoder := capnp.NewPackedEncoder(w)
	arena := make([]byte, 4096)

	var outErr error

	i.tree.Scan(func(key string, off Off) bool {
		msg, seg := capnp.NewSingleSegmentMessage(arena[:0])
		entry, err := indexdisk.NewRootEntry(seg)
		if err != nil {
			outErr = err
			return false
		}

		entry.SetKey(key)
		entry.SetOff(int64(off))
		if err := encoder.Encode(msg); err != nil {
			outErr = err
			return false
		}

		return true
	})

	return outErr
}

func (i *Index) Unmarshal(r io.Reader) error {
	decoder := capnp.NewPackedDecoder(r)

	tree := btree.Map[string, Off]{}
	for {
		msg, err := decoder.Decode()
		if err == io.EOF {
			break
		} else if err != nil {
			return fmt.Errorf("decode: %w", err)
		}

		entry, err := indexdisk.ReadRootEntry(msg)
		if err != nil {
			return fmt.Errorf("read: %w", err)
		}

		key, err := entry.Key()
		if err != nil {
			return fmt.Errorf("alloc: %w", err)
		}

		off := Off(entry.Off())
		i.minKnown = min(off, i.minKnown)
		i.maxKnown = max(off, i.maxKnown)
		tree.Set(key, off)
	}

	i.tree = &tree
	return nil
}
