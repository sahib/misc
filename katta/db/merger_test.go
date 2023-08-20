package db

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/sahib/misc/katta/segment"
	"github.com/sahib/misc/katta/wal"
	"github.com/stretchr/testify/require"
	"github.com/tidwall/btree"
)

// ABCTree produces a dummy tree filled with the
// lowercase a-z keys. The values have a _val prefix.
func ABCTree(first, step byte) *btree.Map[string, segment.Value] {
	tree := &btree.Map[string, segment.Value]{}
	for off := byte(first); off < 26; off += step {
		key := segment.ABCKeyFromOff(off)
		val := segment.ABCValueFromOff(off)
		tree.Set(key, val)
	}

	return tree
}

// ABCSegment produces a dummy segment filled with the
// lowercase a-z keys. The values have a _val prefix.
func ABCSegment(t *testing.T, dir string, id segment.ID, first, step byte) *segment.Segment {
	seg, err := segment.FromTree(dir, id, ABCTree(first, step))
	require.NoError(t, err)
	return seg
}

func TestDBMerger(t *testing.T) {
	dir, err := os.MkdirTemp("", t.Name())
	require.NoError(t, err)
	defer os.RemoveAll(dir)

	segmentDir := filepath.Join(dir, "segments")
	require.NoError(t, os.MkdirAll(segmentDir, 0700))

	ABCSegment(t, segmentDir, segment.ID(1), 0, 2)
	ABCSegment(t, segmentDir, segment.ID(2), 1, 2)
	ABCSegment(t, segmentDir, segment.ID(3), 0, 1)

	db, err := Open(dir, DefaultOptions())
	require.NoError(t, err)

	nMerged, err := db.Merge()
	require.NoError(t, err)
	require.Equal(t, 3, nMerged)

	// Calling it a second time should not do anything:
	nMerged, err = db.Merge()
	require.NoError(t, err)
	require.Equal(t, 0, nMerged)

	mergedSeg, ok := db.registry.ByID(3)
	require.True(t, ok, "no merged segment")

	mr, err := mergedSeg.Reader()
	require.NoError(t, err)

	var off byte
	var entry wal.Entry
	for mr.Next(&entry) {
		expKey := segment.ABCKeyFromOff(off)
		expVal := segment.ABCValueFromOff(off)

		require.Equal(t, expKey, entry.Key)
		require.Equal(t, expVal.Data, entry.Val)
		off++
	}

	require.NoError(t, mr.Err())
	require.NoError(t, db.Close())
}

// TODO: test with duplicated keys
