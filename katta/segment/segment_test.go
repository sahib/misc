package segment

import (
	"os"
	"testing"

	"github.com/sahib/misc/katta/wal"
	"github.com/stretchr/testify/require"
)

func TestSegmentPaths(t *testing.T) {
	s := &Segment{id: 0x17, dir: "/tmp"}
	require.Equal(t, ID(0x17), s.ID())
	require.Equal(t, "/tmp/00000017.seg", s.Path())
	require.Equal(t, "/tmp/00000017.idx", s.IndexPath())
}

func TestSegmentFromTree(t *testing.T) {
	dir, err := os.MkdirTemp("", t.Name())
	require.NoError(t, err)
	defer os.RemoveAll(dir)

	seg := ABCSegment(t, dir, 0x17)
	ks := seg.Index().Tree().Keys()
	for off := 0; off < 26; off++ {
		key := string([]byte{byte('a' + off)})
		require.Equal(t, key, ks[off])
	}

	wr, err := seg.Reader()
	require.NoError(t, err)
	defer wr.Close()

	var count int
	var entry wal.Entry
	for wr.Next(&entry) {
		expKey := string([]byte{byte('a' + count)})
		expVal := []byte("val_" + expKey)
		count++

		require.Equal(t, expKey, entry.Key)
		require.Equal(t, expVal, entry.Val)
	}

	require.NoError(t, wr.Err())

	_, err = LoadSegment(dir, seg.ID())
	require.NoError(t, err)
}
