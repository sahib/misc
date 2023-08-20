package segment

import (
	"testing"

	"github.com/stretchr/testify/require"
	"github.com/tidwall/btree"
)

func ABCKeyFromOff(off byte) string {
	return string([]byte{'a' + off})
}

func ABCValueFromOff(off byte) Value {
	key := ABCKeyFromOff(off)
	return Value{Data: []byte("val_" + key)}
}

// ABCTree produces a dummy tree filled with the
// lowercase a-z keys. The values have a _val prefix.
func ABCTree() *btree.Map[string, Value] {
	tree := &btree.Map[string, Value]{}
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
