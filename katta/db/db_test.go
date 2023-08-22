package db

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/sahib/misc/katta/segment"
	"github.com/sahib/misc/katta/wal"
	"github.com/stretchr/testify/require"
)

func TestDBMemOnly(t *testing.T) {
	dir, err := os.MkdirTemp("", t.Name())
	require.NoError(t, err)
	defer os.RemoveAll(dir)

	db, err := Open(dir, DefaultOptions())
	require.NoError(t, err)

	_, err = db.Get("key")
	require.Equal(t, ErrKeyNotFound, err)

	require.NoError(t, db.Set("key", []byte("value")))
	val, err := db.Get("key")
	require.Equal(t, []byte("value"), val)

	require.NoError(t, db.Del("key"))
	_, err = db.Get("key")
	require.Equal(t, ErrKeyNotFound, err)

	require.NoError(t, db.Close())
}

func TestDBExistingDir(t *testing.T) {
	dir, err := os.MkdirTemp("", t.Name())
	require.NoError(t, err)
	defer os.RemoveAll(dir)

	segmentDir := filepath.Join(dir, "segments")
	require.NoError(t, os.MkdirAll(segmentDir, 0700))

	segment.ABCSegment(t, segmentDir, segment.ID(1))

	db, err := Open(dir, DefaultOptions())
	require.NoError(t, err)

	// Nothing in the memory store right now.
	// Get() needs to go to the segment for this.
	for off := byte(0); off < 26; off++ {
		gotVal, err := db.Get(segment.ABCKeyFromOff(off))
		require.NoError(t, err)

		expVal := segment.ABCValueFromOff(off)
		require.Equal(t, expVal, gotVal)
	}

	require.NoError(t, db.Close())
}

func TestDBNonEmptyWAL(t *testing.T) {
	dir, err := os.MkdirTemp("", t.Name())
	require.NoError(t, err)
	defer os.RemoveAll(dir)

	// Write a fake wal with some key/values:
	walPath := filepath.Join(dir, "wal")
	walFD, err := os.OpenFile(
		walPath,
		os.O_APPEND|os.O_RDWR|os.O_CREATE,
		0600,
	)

	require.NoError(t, err)
	ww := wal.NewWriter(walFD)
	for off := byte(0); off < 26; off++ {
		key := segment.ABCKeyFromOff(off)
		val := segment.ABCValueFromOff(off)
		require.NoError(t, ww.Append(key, val))
	}
	require.NoError(t, walFD.Close())

	db, err := Open(dir, DefaultOptions())
	require.NoError(t, err)

	// Nothing in the memory store right now.
	// Get() needs to go to the segment for this.
	for off := byte(0); off < 26; off++ {
		gotVal, err := db.Get(segment.ABCKeyFromOff(off))
		require.NoError(t, err)

		expVal := segment.ABCValueFromOff(off)
		require.Equal(t, expVal, gotVal)
	}

	require.NoError(t, db.Close())
}

func TestDBFlushSegment(t *testing.T) {
	dir, err := os.MkdirTemp("", t.Name())
	require.NoError(t, err)
	defer os.RemoveAll(dir)

	db, err := Open(dir, Options{MaxElemsInMemory: 10})
	require.NoError(t, err)

	for off := byte(0); off < 26; off++ {
		key := segment.ABCKeyFromOff(off)
		val := segment.ABCValueFromOff(off)
		require.NoError(t, db.Set(key, val))
	}

	for off := byte(0); off < 26; off++ {
		key := segment.ABCKeyFromOff(off)
		gotVal, err := db.Get(key)
		require.NoError(t, err)

		expVal := segment.ABCValueFromOff(off)
		require.Equal(t, expVal, gotVal)
	}

	// Check what was written to the segment dir:
	segmentDir := filepath.Join(dir, "segments")
	require.NoError(t, os.MkdirAll(segmentDir, 0700))

	dirEntries, err := os.ReadDir(segmentDir)
	require.NoError(t, err)
	require.Len(t, dirEntries, 4)
	require.Equal(t, "00000001.idx", dirEntries[0].Name())
	require.Equal(t, "00000001.seg", dirEntries[1].Name())
	require.Equal(t, "00000002.idx", dirEntries[2].Name())
	require.Equal(t, "00000002.seg", dirEntries[3].Name())

	require.NoError(t, db.Close())
}

// TODO: Test for tombstones.
