package db

import (
	"container/heap"
	"context"
	"errors"
	"fmt"
	"os"
	"sort"
	"sync"
	"time"

	"github.com/sahib/misc/katta/index"
	"github.com/sahib/misc/katta/segment"
	"github.com/sahib/misc/katta/wal"
	"golang.org/x/exp/slog"
)

type merger struct {
	mu       sync.Mutex
	ctx      context.Context
	cancel   func()
	registry *segment.Registry
}

func newMerger(ctx context.Context, registry *segment.Registry) *merger {
	ctx, cancel := context.WithCancel(ctx)
	return &merger{
		ctx:      ctx,
		cancel:   cancel,
		registry: registry,
	}
}

func (m *merger) chooseSegmentsToMerge() ([]*segment.Segment, bool) {
	// NOTE: The choice here is very basic & could be improved. Thoughts:
	// * use at least 2, at most 10
	// * decide based on the cumulated segment size.
	// * decide based on file modification date (older segments preferred)
	// * Should not matter much if called several times.

	segs := m.registry.List()
	if len(segs) < 2 {
		return nil, false
	}

	maxSegs := 4
	if len(segs) < maxSegs {
		maxSegs = len(segs)
	}

	return segs[:maxSegs], true
}

func (m *merger) loop() {
	tckr := time.NewTicker(5 * time.Minute)
	for {
		select {
		case <-tckr.C:
			now := time.Now()
			slog.Info("running merger")
			if nSegments, err := m.run(); err != nil {
				slog.Info("merger failed", "took", time.Since(now), "err", err)
			} else {
				slog.Info("merger finished", "took", time.Since(now), "nsegments", nSegments)
			}
		case <-m.ctx.Done():
			return
		}
	}
}

// stream is an incoming collection of values from a single segment.
type stream struct {
	Reader    *wal.Reader
	Segment   *segment.Segment
	Entry     wal.Entry
	Exhausted bool
}

// consume pops up a single value from the stream
// and puts in the Entry field. If there's nothing
// to fetch Exhausted will be set to true.
func (s *stream) consume() error {
	if s.Reader.Next(&s.Entry) {
		return nil
	}

	if err := s.Reader.Err(); err != nil {
		return fmt.Errorf("merge: read: %w", err)
	}

	// The first reader does not have any entries to read from.
	// Mark this one as exhausted (and sort it to the back therefore)
	s.Exhausted = true
	return nil
}

type streams []*stream

func (s streams) Len() int      { return len(s) }
func (s streams) Swap(i, j int) { s[i], s[j] = s[j], s[i] }
func (s streams) Less(i, j int) bool {
	if s[i].Exhausted != s[j].Exhausted {
		// sort exhausted streams to the back
		return !s[i].Exhausted
	}

	if s[i].Entry.Key != s[j].Entry.Key {
		return s[i].Entry.Key < s[j].Entry.Key
	}

	// Sort by segment ID, so that higher IDs
	// get sorted to the back in case of equal keys.
	// Higher segment -> later date of Set()
	return s[i].Segment.ID() < s[j].Segment.ID()
}

// NOTE: Push & Pop not implemented since we don't need it
//
//	(but still required by Go's heap interface :/ )
func (s *streams) Push(x any) {}
func (s *streams) Pop() any   { return nil }

func (m *merger) zipSegments(segs ...*segment.Segment) (string, *index.Index, error) {
	// Create a temp file to which we will write our merged data.
	segFd, err := os.CreateTemp(m.registry.Dir(), "merge-*.seg")
	if err != nil {
		return "", nil, err
	}

	defer func() {
		segFd.Sync()
		segFd.Close()
	}()

	mergedWriter := wal.NewWriter(segFd)
	mergedIdx := index.New()

	streamsPreAllocated := make(streams, 0, len(segs))
	streams := &streamsPreAllocated
	for _, seg := range segs {
		reader, err := seg.Reader()
		if err != nil {
			return "", nil, fmt.Errorf("segment: reader: %w", err)
		}

		stream := &stream{Reader: reader, Segment: seg}
		*streams = append(*streams, stream)
		if err := stream.consume(); err != nil {
			return "", nil, err
		}
	}

	// Make sure that the heap is initially sorted
	heap.Init(streams)

	// XXX: The merging could benefit greatly from several go routines.
	//      If there's one go routine per segment and each fills up a channel
	//      while the main thread writes the merged segment with the help of
	//      of those channels, then we could expect quite some performance boost.

	var lastEntry *wal.Entry
	for {
		// If, after sorting, the first stream is exhausted we don't have
		// any streams left and we're done.
		lowestStream := (*streams)[0]
		if lowestStream.Exhausted {
			break
		}

		lowestEntry := lowestStream.Entry
		if lastEntry == nil || lastEntry.Key != lowestEntry.Key {
			// Only write the entry if the key changed.
			// This ensure that we take the value from the segment
			// with the highest ID (which means it's the latest version)
			posBefore := mergedWriter.Pos()

			// Filter out deleted values if the last value is a tombstone.
			if !lowestEntry.IsTombstone {
				if err := mergedWriter.Append(lowestEntry.Key, lowestEntry.Val); err != nil {
					return "", nil, fmt.Errorf("merge: write: %w", err)
				}

				mergedIdx.Set(lowestEntry.Key, index.Off(posBefore))
			}
		}

		lastEntry = &lowestEntry

		// Try to fetch the next entry from the first available reader:
		if err := lowestStream.consume(); err != nil {
			return "", nil, err
		}

		// maintain sorting in O(log n)
		heap.Fix(streams, 0)
	}

	return segFd.Name(), mergedIdx, nil
}

func (m *merger) merge(segs ...*segment.Segment) error {
	if len(segs) < 2 {
		return errors.New("merge: not enough segments passed")
	}

	mergedSegPath, mergedIdx, err := m.zipSegments(segs...)
	if err != nil {
		return fmt.Errorf("zip: %w", err)
	}

	// Make sure the resulting index is rather small.
	// Depending on the size of the segments, we might have
	// some additional memory peak in zipSegments() though
	mergedIdx.Sparsify(100)

	// Sort with highest ID first:
	sort.Slice(segs, func(i, j int) bool {
		return segs[i].ID() > segs[j].ID()
	})

	if err := os.Rename(mergedSegPath, segs[0].Path()); err != nil {
		return fmt.Errorf("merge: rename: %w", err)
	}

	idxFd, err := os.OpenFile(
		segs[0].IndexPath(),
		os.O_CREATE|os.O_TRUNC|os.O_WRONLY,
		0600,
	)
	if err != nil {
		return fmt.Errorf("merge: index-write: %w", err)
	}

	if err := mergedIdx.Marshal(idxFd); err != nil {
		return fmt.Errorf("merge: index: %w", err)
	}

	if err := idxFd.Close(); err != nil {
		return fmt.Errorf("merge: index-close: %w", err)
	}

	// Make sure to update the registry.
	dropIDs := make([]segment.ID, 0, len(segs[1:]))
	for _, seg := range segs[1:] {
		dropIDs = append(dropIDs, seg.ID())
	}

	return m.registry.Squash(segs[0].ID(), mergedIdx, dropIDs)
}

func (m *merger) run() (int, error) {
	// Make sure only one Run() can exeute at the same time.
	m.mu.Lock()
	defer m.mu.Unlock()

	segs, ok := m.chooseSegmentsToMerge()
	if !ok {
		// Nothing to do.
		return 0, nil
	}

	return len(segs), m.merge(segs...)
}

func (m *merger) start() {
	go m.loop()
}

func (m *merger) stop() {
	m.cancel()
}
