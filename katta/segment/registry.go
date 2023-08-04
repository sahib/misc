package segment

import (
	"path/filepath"
	"strconv"
	"strings"

	"golang.org/x/exp/slog"
)

type Registry struct {
	dir      string
	idSeq    int
	segments map[ID]*Segment
}

func LoadDir(dir string) (*Registry, error) {
	matches, err := filepath.Glob(filepath.Join(dir, "*.seg"))
	if err != nil {
		return nil, err
	}

	segmentsByID := make(map[ID]*Segment, len(matches))
	for _, match := range matches {
		segmentName := strings.TrimSuffix(filepath.Base(match), ".seg")
		segmentID, err := strconv.Atoi(segmentName)
		if err != nil {
			slog.Warn("bad segment name", "name", segmentName, "err", err)
			continue
		}

		segment, err := NewSegment(dir, ID(segmentID))
		if err != nil {
			return nil, err
		}

		segmentsByID[ID(segmentID)] = segment
	}

	return &Registry{
		dir:      dir,
		idSeq:    int(len(segmentsByID)),
		segments: segmentsByID,
	}, nil
}

func (r *Registry) List() []Segment {
	segments := make([]Segment, 0, len(r.segments))
	for _, segment := range r.segments {
		segments = append(segments, *segment)
	}

	return segments
}

func (r *Registry) NewSegment() *Segment {
	id := r.NextID()
	// TODO: Do not load index here - there is none yet.
	seg := NewSegment(r.dir, id)
	r.segments[id] = seg
	return seg
}

func (r *Registry) ByID(id ID) (*Segment, bool) {
	seg, ok := r.segments[id]
	return seg, ok
}

// NextID returns the next ID for a segment.
// Subsequent calls produce different IDs.
func (r *Registry) NextID() ID {
	r.idSeq++
	return ID(r.idSeq)
}
