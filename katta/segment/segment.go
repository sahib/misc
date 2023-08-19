package segment

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/sahib/misc/katta/index"
	"github.com/sahib/misc/katta/wal"
	"github.com/tidwall/btree"
)

// ID references a single segment
type ID int32

// Value is a stored value in a segment
type Value struct {
	Data        []byte
	IsTombstone bool
}

type Segment struct {
	id  ID
	dir string
	idx *index.Index
}

func basePath(dir string, id ID) string {
	return filepath.Join(dir, fmt.Sprintf("%08X", id))
}

func segmentPath(dir string, id ID) string {
	return basePath(dir, id) + ".seg"
}

func indexPath(dir string, id ID) string {
	return basePath(dir, id) + ".idx"
}

func LoadSegment(dir string, id ID) (*Segment, error) {
	// TODO: A good improvement in terms of safety would be to
	//       regenerate the index if it was not found/could not be read.
	//       The data in the segment is sufficient to build a new index.
	idxFd, err := os.Open(indexPath(dir, id))
	if err != nil {
		return nil, err
	}

	defer idxFd.Close()

	idx := index.New()
	if err := idx.Unmarshal(idxFd); err != nil {
		return nil, err
	}

	return &Segment{
		id:  id,
		dir: dir,
		idx: idx,
	}, nil
}

func FromTree(dir string, id ID, tree *btree.Map[string, Value]) (*Segment, error) {
	idx := index.New()
	seg := &Segment{
		id:  id,
		dir: dir,
		idx: idx,
	}

	segFd, err := os.OpenFile(
		segmentPath(dir, id),
		os.O_CREATE|os.O_TRUNC|os.O_WRONLY,
		0600,
	)

	if err != nil {
		return nil, fmt.Errorf("segment-open: %w", err)
	}
	defer segFd.Close()

	w := wal.NewWriter(segFd)
	iter := tree.Iter()
	for iter.Next() {
		key := iter.Key()
		val := iter.Value()
		pos := w.Pos()
		idx.Set(key, index.Off(pos))

		// NOTE:: If tombstone, then val.Data is empty.
		// TODO: Do we really need tombstone as bool?
		if err := w.Append(key, val.Data); err != nil {
			return nil, err
		}
	}

	// make sure we do not write all of the index,
	// but only parts of it. Could be also done as part
	// of the loop above.
	idx.Sparsify(1000)

	idxFd, err := os.OpenFile(
		indexPath(dir, id),
		os.O_CREATE|os.O_TRUNC|os.O_WRONLY,
		0600,
	)

	if err != nil {
		return nil, fmt.Errorf("index-open: %w", err)
	}
	defer idxFd.Close()

	if err := idx.Marshal(idxFd); err != nil {
		return nil, fmt.Errorf("index: %w", err)
	}

	return seg, nil
}

func (s *Segment) Index() *index.Index {
	return s.idx
}

func (s *Segment) IndexPath() string {
	return indexPath(s.dir, s.id)
}

func (s *Segment) Path() string {
	return segmentPath(s.dir, s.id)
}

func (s *Segment) Reader() (*wal.Reader, error) {
	fd, err := os.Open(s.Path())
	if err != nil {
		return nil, err
	}

	return wal.NewReader(fd), nil
}

func (s *Segment) ID() ID {
	return s.id
}

func (s *Segment) UpdateIndex(idx *index.Index) {
	s.idx = idx
}
