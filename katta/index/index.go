package index

import (
	"fmt"
	"io"

	"capnproto.org/go/capnp/v3"
	"github.com/sahib/misc/katta/index/indexdisk"
	"github.com/tidwall/btree"
)

// Off is a offset of a value in the index
type Off int32

const (
	// NoOff is returned by index lookup if no such key exists.
	NoOff = Off(-1)
)

// Index maps keys to offsets. It is supposed to be created for each segment.
// The index expects that all keys are feed to the index. The implementation
// is sparse, i.e. not all keys are stored in-memory, but only a small fraction
// of them. The Lookup function will return a range therefore.
type Index struct {
	tree *btree.Map[string, Off]
}

// New returns an empty index.
func New() *Index {
	return &Index{
		tree: &btree.Map[string, Off]{},
	}
}

func (i *Index) Set(key string, off Off) {
	i.tree.Set(key, off)
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
		// all keys in our index are smaller than the key
		// that was searched for.
		return NoOff, NoOff
	}

	if iter.Prev() {
		// We have the closest value < `key`. Same edge case
		// as above applies, as this might not happen
		lo = iter.Value()
	} else {
		// tree is empty or no previous value exists.
		// value is out of range of this index.
		return NoOff, NoOff
	}

	return lo, hi
}

// Sparsify reduces the elements in the index to something
// close to `maxElems`. It will leave the min and max value intact.
func (i *Index) Sparsify(maxElems int) {
	if maxElems < 0 {
		return
	}

	l := i.tree.Len()
	if l < maxElems {
		return
	}

	getRidOffTotal := l - maxElems
	getRidOneEvery := float64(l) / float64(getRidOffTotal)

	count := 0.0

	// in Lookup() we rely on the min and max value
	// being present in the tree. Take care to not delete them.
	_, minOff, _ := i.tree.Min()
	_, maxOff, _ := i.tree.Max()

	deleteKeys := make([]string, 0, getRidOffTotal)
	i.tree.ScanMut(func(key string, val Off) bool {
		count += 1
		if count >= getRidOneEvery && val != minOff && val != maxOff {
			count -= getRidOneEvery
			deleteKeys = append(deleteKeys, key)
		}

		return true
	})

	// NOTE: Deleting while iterating leads to funny results.
	for _, key := range deleteKeys {
		i.tree.Delete(key)
	}
}

// Marshal writes index to `w` as a compact binary representation.
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

// Unmarshal loads index from the data in `r`, if
// it has been marshalled with Marshal() before.
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
		tree.Set(key, off)
	}

	i.tree = &tree
	return nil
}
