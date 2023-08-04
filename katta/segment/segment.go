package segment

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/sahib/misc/katta/wal"
)

type ID int32

type Segment struct {
	id  ID
	dir string
	idx *Index
}

func NewSegment(dir string, id ID) (*Segment, error) {
	idxPath := filepath.Join(dir, fmt.Sprintf("%08X.idx", id))
	idxFd, err := os.Open(idxPath)
	if err != nil {
		return nil, err
	}

	defer idxFd.Close()

	// TODO: How to pass the max elements here? Probably pass it via Registry.
	idx := NewIndex(100)
	if err := idx.Unmarshal(idxFd); err != nil {
		return nil, err
	}

	return &Segment{
		id:  id,
		dir: dir,
		idx: idx,
	}, nil
}

func (s *Segment) Index() *Index {
	return s.idx
}

func (s *Segment) Path() string {
	return filepath.Join(s.dir, fmt.Sprintf("%08X.seg", s.id))
}

func (s *Segment) Reader() (*wal.Reader, error) {
	fd, err := os.Open(s.Path())
	if err != nil {
		return nil, err
	}

	return wal.NewReader(fd), nil
}

func (s *Segment) Writer() *wal.Writer {
	// TODO: Just use wal.writer here.
	return nil
}
