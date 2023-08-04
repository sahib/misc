package segment

type Registry struct {
}

func LoadDir(dir string) (*Registry, error) {
	

	return nil, nil
}

func (r *Registry) List() []*Segment {
	return nil
}

func (r *Registry) NewSegment() *Segment {
	// TODO: Create one if not there yet.
	return nil
}

func (r *Registry) ByID(id ID) (*Segment, bool) {
	return &Segment{}, false
}

// NextID returns the next ID for a segment.
// Subsequent calls produce different IDs.
func (r *Registry) NextID() ID {
	return 0
}
