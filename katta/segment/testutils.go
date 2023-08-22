package segment

import (
	"fmt"
	"testing"

	"github.com/sahib/misc/katta/index"
	"github.com/stretchr/testify/require"
)

func ABCKeyFromOff(off byte) string {
	return string([]byte{'a' + off})
}

func ABCValueFromOff(off byte) []byte {
	key := ABCKeyFromOff(off)
	return []byte("val_" + key)
}

// ABCTree produces a dummy tree filled with the
// lowercase a-z keys. The values have a _val prefix.
func ABCTree() *Tree {
	tree := &Tree{}
	for off := byte(0); off < 26; off++ {
		key := ABCKeyFromOff(off)
		val := ABCValueFromOff(off)
		tree.Set(key, val)
	}

	return tree
}

// ABCSegment produces a dummy segment filled with the
// lowercase a-z keys. The values have a _val prefix.
func ABCSegment(t *testing.T, dir string, id ID) *Segment {
	seg, err := FromTree(dir, id, ABCTree())
	require.NoError(t, err)
	return seg
}

func OffKey(off index.Off) string {
	return fmt.Sprintf("%010d", off)
}

func OffVal(off index.Off) []byte {
	return []byte("val_" + OffKey(off))
}

func OffTree(start, step, stop index.Off) *Tree {
	tree := &Tree{}
	for off := start; off < stop; off += step {
		key := OffKey(off)
		val := OffVal(off)
		tree.Set(key, val)
	}

	return tree
}

func OffSegment(t *testing.T, dir string, id ID, first, step, stop index.Off) *Segment {
	seg, err := FromTree(dir, id, OffTree(first, step, stop))
	require.NoError(t, err)
	return seg
}
