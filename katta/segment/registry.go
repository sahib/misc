package segment

import (
	"path/filepath"
	"strconv"
	"strings"

	"github.com/tidwall/btree"
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

		segment, err := LoadSegment(dir, ID(segmentID))
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

func (r *Registry) List() []*Segment {
	segments := make([]*Segment, 0, len(r.segments))
	for _, segment := range r.segments {
		segments = append(segments, segment)
	}

	return segments
}

func (r *Registry) Dir() string {
	return r.dir
}

func (r *Registry) Add(tree *btree.Map[string, Value]) (*Segment, error) {
	id := r.NextID()
	seg, err := FromTree(r.dir, id, tree)
	if err != nil {
		return nil, err
	}

	r.segments[id] = seg
	return seg, nil
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

func (r *Registry) Drop(id ID) {
	delete(r.segments, id)
}
