package segment

import (
	"os"
	"path/filepath"
	"sort"
	"strconv"
	"strings"
	"sync"

	"github.com/sahib/misc/katta/index"
	"github.com/tidwall/btree"
	"golang.org/x/exp/slog"
)

// Tree is the in-memory representation of key-value pairs.
type Tree struct {
	btree.Map[string, []byte]
}

// Registry takes care of collecting all known segments
// and giving easy access to them.
type Registry struct {
	mu       sync.Mutex
	dir      string
	idSeq    int
	segments map[ID]*Segment
}

// LoadDir loads the database structure from `dir`.
// `dir` might be empty, but it should be writable.
func LoadDir(dir string) (*Registry, error) {
	matches, err := filepath.Glob(filepath.Join(dir, "*.seg"))
	if err != nil {
		return nil, err
	}

	segmentsByID := make(map[ID]*Segment, len(matches))
	for _, match := range matches {
		segmentName := strings.TrimSuffix(filepath.Base(match), ".seg")
		segmentID, err := strconv.ParseInt(segmentName, 16, 64)
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

// List returns a list of all known segments.
func (r *Registry) List() []*Segment {
	r.mu.Lock()
	defer r.mu.Unlock()

	segments := make([]*Segment, 0, len(r.segments))
	for _, segment := range r.segments {
		// copy segment here to caller cannot modify it.
		segments = append(segments, &Segment{
			id:  segment.id,
			dir: segment.dir,
			idx: segment.idx,
		})
	}

	sort.Slice(segments, func(i, j int) bool {
		return segments[i].id < segments[j].id
	})

	return segments
}

func (r *Registry) Dir() string {
	r.mu.Lock()
	defer r.mu.Unlock()

	return r.dir
}

// Add takes the data from `tree` and generates a segment
// and an index from it.
func (r *Registry) Add(tree *Tree) (*Segment, error) {
	r.mu.Lock()
	defer r.mu.Unlock()

	id := r.nextID()
	seg, err := FromTree(r.dir, id, tree)
	if err != nil {
		return nil, err
	}

	r.segments[id] = seg
	return seg, nil
}

// ByID returns a segment by it's ID.
// If it does not exist, the second return is false.
func (r *Registry) ByID(id ID) (*Segment, bool) {
	r.mu.Lock()
	defer r.mu.Unlock()

	seg, ok := r.segments[id]
	return seg, ok
}

// nextID returns the next ID for a segment.
// Subsequent calls produce different IDs.
func (r *Registry) nextID() ID {
	r.idSeq++
	return ID(r.idSeq)
}

// Squash confirms a successful merge of several segments to one.
// The `id` is the id of the merged segment, newIdx the newly generated
// inde and drops contains the ids of the segments that are now
// not required anymore.
func (r *Registry) Squash(id ID, newIdx *index.Index, drops []ID) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	// Update index of the newly merged one.
	if seg, ok := r.segments[id]; ok {
		seg.idx = newIdx
	}

	// Drop all other segments from our knowledge and fs:
	var lastErr error
	for _, dropID := range drops {
		segPath := segmentPath(r.dir, dropID)
		if err := os.Remove(segPath); err != nil {
			lastErr = err
		}

		delete(r.segments, dropID)
	}

	return lastErr
}
