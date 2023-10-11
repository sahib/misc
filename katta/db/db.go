package db

import (
	"context"
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"

	"github.com/sahib/misc/katta/index"
	"github.com/sahib/misc/katta/segment"
	"github.com/sahib/misc/katta/wal"
)

// XXX: Range queries are not implemented at the moment.
//      Think about it: What needs to be changed to support it?
//      Is there maybe already code that does something similar?
//
//      Range queries could have an API that looks like this:
//
//      Iter(min, max string) (*Iter, error)
//
//      Where "*Iter" is a struct similar to wal.Reader
//      (i.e. it has a Next() and a Err())

// XXX: We also have no way to support transactions yet.
//      How can a caller make sure to retrieve a bunch of related
//      values (i.e. several Get() calls) without changing in between?
//      And how can a caller write several related values and make
//      sure that none of them are overwritten in between?
//
//      Hint: This is a very hard problem to solve completely.

var (
	// ErrKeyNotFound is returned by the API if no such
	// key was found anywhere or if it was deleted explicitly.
	ErrKeyNotFound = errors.New("no such key")
)

// Store is the API to acces the database
type Store struct {
	registry *segment.Registry
	merger   *merger
	wal      *wal.Writer
	mem      *segment.Tree
	walFD    *os.File
	cancel   func()

	// Unpacked & validated options go here:
	maxElemsInMemory int
}

// Options holds all possible options for the store
type Options struct {
	// MaxElemsInMemory is the number of elements that
	// maybe held at most at the same time in memory.
	MaxElemsInMemory int
}

// Validate checks that all options are set correctly
func (o Options) Validate() error {
	if o.MaxElemsInMemory < 10 {
		return fmt.Errorf("MaxElemsInMemory must be at least 10")
	}

	return nil
}

// DefaultOptions returns sane default options
func DefaultOptions() Options {
	return Options{
		MaxElemsInMemory: 500,
	}
}

func walToMemTree(rs io.ReadSeeker) (*segment.Tree, error) {
	r := wal.NewReader(rs)
	t := &segment.Tree{}

	var entry wal.Entry
	for r.Next(&entry) {
		t.Set(entry.Key, entry.Val)
	}

	if err := r.Err(); err != nil {
		return nil, err
	}

	return t, nil
}

// Open loads a database from `dir` using the options in `opts`.
// If `dir` is empty or does not exist it is created newly.
func Open(dir string, opts Options) (*Store, error) {
	if err := opts.Validate(); err != nil {
		return nil, fmt.Errorf("validation: %w", err)
	}

	segmentDir := filepath.Join(dir, "segments")
	reg, err := segment.LoadDir(segmentDir)
	if err != nil {
		return nil, fmt.Errorf("registry: %w", err)
	}

	if err := os.MkdirAll(segmentDir, 0700); err != nil {
		return nil, fmt.Errorf("wal-mkdir: %w", err)
	}

	// Load and restore old WAL here
	walPath := filepath.Join(dir, "wal")
	walFD, err := os.OpenFile(
		walPath,
		os.O_APPEND|os.O_RDWR|os.O_CREATE,
		0600,
	)
	if err != nil {
		return nil, fmt.Errorf("wal: open: %w", err)
	}

	mem, err := walToMemTree(walFD)
	if err != nil {
		return nil, fmt.Errorf("wal: parse: %w", err)
	}

	ctx, cancel := context.WithCancel(context.Background())
	merger := newMerger(ctx, reg)
	merger.start()

	return &Store{
		registry:         reg,
		merger:           merger,
		mem:              mem,
		wal:              wal.NewWriter(walFD),
		walFD:            walFD,
		cancel:           cancel,
		maxElemsInMemory: opts.MaxElemsInMemory,
	}, nil
}

// XXX: A bloom filter could be used to cache "not found" errors.
//      If a key does not exist, we still have to go over all indexes
//      and check with I/O if they key is there. That's expensive and
//      a bloom filter could cache a large chunk of those cases.

// Get returns the value associated with key or an error.
// The error might be ErrKeyNotFound if it was not found or deleted.
func (s *Store) Get(key string) ([]byte, error) {
	if v, ok := s.mem.Get(key); ok {
		if v == nil {
			// was explicitly deleted.
			return nil, ErrKeyNotFound
		}

		return v, nil
	}

	for _, seg := range s.registry.List() {
		lo, hi := seg.Index().Lookup(key)
		if lo == index.NoOff || hi == index.NoOff {
			continue
		}

		r, err := seg.Reader()
		if err != nil {
			return nil, fmt.Errorf("read: %w", err)
		}

		if _, err := r.Seek(int64(lo), io.SeekStart); err != nil {
			return nil, fmt.Errorf("seek: %w", err)
		}

		var entry wal.Entry
		for r.Next(&entry) && index.Off(entry.Pos) <= hi {
			// Find the right entry, as the index is range
			// based and only gets you near the right entry.
			if entry.Key == key {
				if entry.IsTombstone {
					// The entry is there, but it's marked as deleted.
					// Act as if it was never there.
					return nil, ErrKeyNotFound
				}

				// XXX: How long is the returned value valid? Does it survive
				//      another call to Get() with a different key?
				return entry.Val, nil
			}
		}

		if err := r.Err(); err != nil {
			return nil, fmt.Errorf("read: %w", err)
		}
	}

	return nil, ErrKeyNotFound
}

func (s *Store) flushToSegment() error {
	_, err := s.registry.Add(s.mem)
	if err != nil {
		return err
	}

	// Clear old memtable and start fresh:
	s.mem = &segment.Tree{}

	// we did write a segment with the old data to disk.
	// time to clear the WAL as the values there are stale.
	if err := s.walFD.Truncate(0); err != nil {
		return fmt.Errorf("wal: truncate: %w", err)
	}

	return nil
}

func (s *Store) set(key string, val []byte) error {
	if err := s.wal.Append(key, val); err != nil {
		return fmt.Errorf("wal: %w", err)
	}

	s.mem.Set(key, val)
	if s.mem.Len() < s.maxElemsInMemory {
		return nil
	}

	return s.flushToSegment()
}

// Set sets key to `val`. It is immediately visible to Get()
func (s *Store) Set(key string, val []byte) error {
	return s.set(key, val)
}

// Del removes the value associated with `key`. The storage
// is not immediately released.
func (s *Store) Del(key string) error {
	return s.set(key, nil)
}

// Merge runs the segment merging process explicitly.
// The number of merged segments is returned. You should
// call it in a loop to merge all segments.
func (s *Store) Merge() (int, error) {
	return s.merger.run()
}

// Close frees up resources.
func (s *Store) Close() error {
	s.merger.stop()
	s.cancel()
	s.walFD.Close()
	return nil
}
