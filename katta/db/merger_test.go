package db

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/sahib/misc/katta/index"
	"github.com/sahib/misc/katta/segment"
	"github.com/sahib/misc/katta/wal"
	"github.com/stretchr/testify/require"
)

func TestDBMerger(t *testing.T) {
	dir, err := os.MkdirTemp("", t.Name())
	require.NoError(t, err)
	defer os.RemoveAll(dir)

	segmentDir := filepath.Join(dir, "segments")
	require.NoError(t, os.MkdirAll(segmentDir, 0700))

	segment.OffSegment(t, segmentDir, segment.ID(1), 0, 2, 100)
	segment.OffSegment(t, segmentDir, segment.ID(2), 1, 2, 100)
	segment.OffSegment(t, segmentDir, segment.ID(3), 30, 1, 30)

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

	var off index.Off
	var entry wal.Entry
	for mr.Next(&entry) {
		expKey := segment.OffKey(off)
		expVal := segment.OffVal(off)

		require.Equal(t, expKey, entry.Key)
		require.Equal(t, expVal, entry.Val)
		off++
	}

	require.NoError(t, mr.Err())
	require.NoError(t, db.Close())
}

// TODO: test with duplicated keys
