package kv

import (
	"context"
	"errors"
	"fmt"
	"io/ioutil"
	"os"
	"sort"
	"time"

	"github.com/sahib/misc/katta/index"
	"github.com/sahib/misc/katta/segment"
	"github.com/sahib/misc/katta/wal"
	"golang.org/x/exp/slog"
)

type Merger struct {
	ctx      context.Context
	cancel   func()
	registry *segment.Registry
}

func NewMerger(ctx context.Context, registry *segment.Registry) *Merger {
	ctx, cancel := context.WithCancel(ctx)
	return &Merger{
		ctx:      ctx,
		cancel:   cancel,
		registry: registry,
	}
}

func (m *Merger) chooseSegmentsToMerge() ([]*segment.Segment, bool) {
	// TODO: The choice here is very basic & could be improved. Thoughts:
	// -> use at least 2, at most 10
	// -> decide based on the cumulated segment size.
	// -> decide based on file modification date (older segments preferred)
	// -> Should not matter much if called several times.

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

func (m *Merger) loop() {
	tckr := time.NewTicker(5 * time.Minute)
	for {
		select {
		case <-tckr.C:
			segs, ok := m.chooseSegmentsToMerge()
			if !ok {
				continue
			}

			now := time.Now()
			slog.Info("running merger on", segs)
			if err := m.merge(segs...); err != nil {
				slog.Error("merge failed", err)
			}

			slog.Info("merger finished", "took", time.Since(now))
		case <-m.ctx.Done():
			return
		}
	}
}

type step struct {
	Reader  *wal.Reader
	Segment *segment.Segment
	Entry   wal.Entry
}

type steps []step

func (s steps) Len() int {
	return len(s)
}

func (s steps) Less(i, j int) bool {
	if s[i].Entry.Key != s[j].Entry.Key {
		return s[i].Entry.Key < s[j].Entry.Key
	}

	// Sort by segment ID, so that higher IDs
	// get sorted to the back.
	return s[i].Segment.ID() < s[j].Segment.ID()
}

func (s steps) Swap(i, j int) {
	s[i], s[j] = s[j], s[i]
}

// TODO: Split this in two parts:
// - Part that does the actual merging.
// - Part that does the high level logic of using the merged segment.
func (m *Merger) merge(segs ...*segment.Segment) error {
	if len(segs) < 2 {
		return errors.New("merge: not enough segments passed")
	}

	segFd, err := ioutil.TempFile(m.registry.Dir(), "merge-*.seg")
	if err != nil {
		return err
	}
	defer segFd.Close()

	mergedWriter := wal.NewWriter(segFd)
	mergedIdx := index.New()

	steps := steps(make([]step, 0, len(segs)))
	for _, seg := range segs {
		reader, err := seg.Reader()
		if err != nil {
			return fmt.Errorf("segment: reader: %w", err)
		}

		step := step{Reader: reader}

		// read initial value required for deciding where
		// the merge below begins.
		if reader.Next(&step.Entry) == false {
			if err := reader.Err(); err != nil {
				return fmt.Errorf("segment: initial-read: %w", err)
			}

			// seems to be an empty segment...
			continue
		}

		steps = append(steps, step)
	}

	// TODO: The merging could benefit greatly from several go routines.
	//       If there's one go routine per segment and each fills up a channel
	//       while the main thread writes the merged segment with the help of
	//       of those channels, then we could expect quite some performance boost.

	// Make sure the values we initially read are in order,
	// with the lowest item in the front.
	sort.Sort(steps)

	var dedupedEntry wal.Entry
	for len(steps) > 0 {
		currEntry := steps[0].Entry
		if dedupedEntry.Key != currEntry.Key {
			// Only write the entry if the key changed.
			// This ensure that we take the value from the segment
			// with the highest ID (which means it's the latest version)
			posBefore := mergedWriter.Pos()
			if err := mergedWriter.Append(currEntry.Key, currEntry.Val); err != nil {
				return fmt.Errorf("merge: write: %w", err)
			}

			mergedIdx.Set(steps[0].Entry.Key, index.Off(posBefore))
		}

		dedupedEntry = currEntry

		// Try to fetch the next entry from the first available reader:
		for len(steps) > 0 && steps[0].Reader.Next(&steps[0].Entry) == false {
			if err := steps[0].Reader.Err(); err != nil {
				return fmt.Errorf("merge: read: %w", err)
			}

			// The first reader does not have any entries to read from.
			// Advance to the next one.
			steps = steps[1:]
		}

		// TODO: This can be optimized if we make "steps" a heap like
		// structure that keeps its order. This would avoid sorting it over
		// and over again.
		sort.Sort(steps)
	}

	sort.Slice(segs, func(i, j int) bool {
		return segs[i].ID() > segs[j].ID()
	})

	// TODO: Locking. Rename() itself is atomic, but the index
	//       write and update of registry is not.

	if err := os.Rename(segFd.Name(), segs[0].Path()); err != nil {
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

	defer idxFd.Close()

	if err := mergedIdx.Marshal(idxFd); err != nil {
		return fmt.Errorf("merge: index: %w", err)
	}

	segs[0].UpdateIndex(mergedIdx)

	for _, seg := range segs[1:] {
		if err := os.Remove(seg.Path()); err != nil {
			return fmt.Errorf("merge: remove: %w", err)
		}

		m.registry.Drop(seg.ID())
	}

	return nil
}

func (m *Merger) Start() {
	go m.loop()
}

func (m *Merger) Stop() {
	m.cancel()
}
