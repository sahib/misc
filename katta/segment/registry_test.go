package segment

import (
	"os"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestRegistry(t *testing.T) {
	dir, err := os.MkdirTemp("", t.Name())
	require.NoError(t, err)
	defer os.RemoveAll(dir)

	for idx := 0; idx < 10; idx++ {
		ABCSegment(t, dir, ID(idx))
	}

	reg, err := LoadDir(dir)
	require.NoError(t, err)

	for idx, seg := range reg.List() {
		require.Equal(t, ID(idx), seg.ID())
	}

	newSeg, err := reg.Add(ABCTree())
	require.NoError(t, err)
	require.Equal(t, ID(11), newSeg.ID())
}
