package index

import (
	"bytes"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestIndexLookupBasic(t *testing.T) {
	idx := New()
	idx.Set("a", 0)
	idx.Set("n", 500)
	idx.Set("z", 1000)

	nMin, nMax := idx.Lookup("n")
	require.Equal(t, nMin, nMax)
	require.Equal(t, Off(500), nMax)

	lMin, lMax := idx.Lookup("l")
	require.Equal(t, Off(0), lMin)
	require.Equal(t, Off(500), lMax)

	oMin, oMax := idx.Lookup("o")
	require.Equal(t, Off(500), oMin)
	require.Equal(t, Off(1000), oMax)

	lowMin, lowMax := idx.Lookup("0")
	require.Equal(t, NoOff, lowMin)
	require.Equal(t, NoOff, lowMax)

	hiMin, hiMax := idx.Lookup("{")
	require.Equal(t, NoOff, hiMin)
	require.Equal(t, NoOff, hiMax)
}

func TestIndexMarshalUnmarshal(t *testing.T) {
	const size = 26

	idx := New()
	for off := Off(0); off < size; off++ {
		key := string([]byte{byte('a' + off)})
		idx.Set(key, off)
	}

	buf := &bytes.Buffer{}
	require.NoError(t, idx.Marshal(buf))

	loadIdx := &Index{}
	require.NoError(t, loadIdx.Unmarshal(buf))

	ks, vs := loadIdx.tree.KeyValues()
	require.Equal(t, size, len(ks))
	require.Equal(t, size, len(vs))

	for off := Off(0); off < size; off++ {
		expectKey := string([]byte{byte('a' + off)})

		k := ks[off]
		v := vs[off]
		require.Equal(t, expectKey, k)
		require.Equal(t, off, v)
	}
}

func TestIndexEmpty(t *testing.T) {
	idx := New()
	lo, hi := idx.Lookup("key")
	require.Equal(t, NoOff, lo)
	require.Equal(t, NoOff, hi)

	idx.Set("key", 1000)
	idx.Delete("key")

	lo, hi = idx.Lookup("key")
	require.Equal(t, NoOff, lo)
	require.Equal(t, NoOff, hi)
}

func TestIndexSparsify(t *testing.T) {
	const size = 26

	idx := New()
	for off := Off(0); off < size; off++ {
		key := string([]byte{byte('a' + off)})
		idx.Set(key, off)
	}

	idx.Sparsify(10)
	ks := idx.tree.Keys()
	require.Equal(t, 11, len(ks))

	// calling twice should not do extra work:
	idx.Sparsify(10)
	ks = idx.tree.Keys()
	require.Equal(t, 11, len(ks))

	// reducing to nothing at all should keep the min/max:
	idx.Sparsify(0)
	ks = idx.tree.Keys()
	require.Equal(t, 2, len(ks))
}
