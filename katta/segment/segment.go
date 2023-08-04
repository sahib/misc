package segment

type Segment struct {
	id  ID
	dir string
	idx *Index
}

func NewSegment(dir string, id ID) *Segment {
	return &Segment{
		id:  id,
		dir: dir,
	}
}

func (s *Segment) Index() *Index {
	// NOTE: load when needed.
	return nil
}

func (s *Segment) Reader() *Reader {
	return nil
}

func (s *Segment) Writer() *Writer {
	return nil
}
