package segment

type Registry struct {
}

func LoadDir(dir string) (*Registry, error) {
	return nil, nil
}

func (r *Registry) List() []*Reader {
	return nil
}

func (r *Registry) ByID(id ID) (*Reader, bool) {
	return &Reader{}, false
}

// NextID returns the next ID for a segment.
// Subsequent calls produce different IDs.
func (r *Registry) NextID() ID {
	return 0
}
