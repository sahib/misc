package kv

import (
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"

	"github.com/sahib/misc/katta/index"
	"github.com/sahib/misc/katta/segment"
	"github.com/sahib/misc/katta/wal"
	"github.com/tidwall/btree"
)

// TODO: Range queries are not implemente at the moment.
//       Have a try! What needs changing?

var (
	ErrKeyNotFound = errors.New("no such key")
)

type Store struct {
	Registry *segment.Registry
	WAL      *wal.Writer
	Mem      *btree.Map[string, segment.Value]
	walFD    *os.File

	// Unpacked & validated options go here:
	maxElemsInMemory int
}

type Options struct {
	// MaxElemsInMemory is the number of elements that
	// maybe held at most at the same time in memory.
	MaxElemsInMemory int

	// TODO: Pack some memory related options here.
}

func (o Options) Validate() error {
	if o.MaxElemsInMemory <= 100 {
		return fmt.Errorf("MaxElemsInMemory must be at least 100")
	}

	return nil
}

func DefaultOptions() Options {
	return Options{
		MaxElemsInMemory: 500,
	}
}

func walToMemTree(rs io.ReadSeeker) (*btree.Map[string, segment.Value], error) {
	r := wal.NewReader(rs)
	t := &btree.Map[string, segment.Value]{}

	var entry wal.Entry
	for r.Next(&entry) {
		t.Set(entry.Key, segment.Value{
			IsTombstone: entry.IsTombstone,
			Data:        entry.Val,
		})
	}

	if err := r.Err(); err != nil {
		return nil, err
	}

	return t, nil
}

func Open(dir string, opts Options) (*Store, error) {
	if err := opts.Validate(); err != nil {
		return nil, fmt.Errorf("validation: %w", err)
	}

	segmentDir := filepath.Join(dir, "segments")
	reg, err := segment.LoadDir(segmentDir)
	if err != nil {
		return nil, fmt.Errorf("registry: %w", err)
	}

	// TODO: Load & restore old WAL here!
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

	return &Store{
		Registry:         reg,
		Mem:              mem,
		WAL:              wal.NewWriter(walFD),
		walFD:            walFD,
		maxElemsInMemory: opts.MaxElemsInMemory,
	}, nil
}

// TODO: A bloom filter could be used to cache "not found" errors.
//       If a key does not exist, we still have to go over all indexes
//       and check with I/O if they key is there. That's expensive and
//       a bloom filter could cache a large chunk of those cases.

func (s *Store) Get(key string) ([]byte, error) {
	if v, ok := s.Mem.Get(key); ok {
		if v.IsTombstone {
			// was explicitly deleted.
			return nil, ErrKeyNotFound
		}

		return v.Data, nil
	}

	for _, seg := range s.Registry.List() {
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
		for r.Next(&entry) && index.Off(entry.Pos) < hi {
			// Find the right entry, as the index is range
			// based and only gets you near the right entry.
			if entry.Key == key {
				if entry.IsTombstone {
					// The entry is there, but it's marked as deleted.
					// Act as if it was never there.
					return nil, ErrKeyNotFound
				}

				// TODO: scope of entry.Val? probably needs to be copied.
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
	_, err := s.Registry.Add(s.Mem)
	if err != nil {
		return err
	}

	// Clear old memtable and start fresh:
	s.Mem = &btree.Map[string, segment.Value]{}

	// we did write a segment with the old data to disk.
	// time to clear the WAL as the values there are stale.
	if err := s.walFD.Truncate(0); err != nil {
		return fmt.Errorf("wal: truncate: %w", err)
	}

	return nil
}

func (s *Store) set(key string, val segment.Value) error {
	if err := s.WAL.Append(key, val.Data); err != nil {
		return fmt.Errorf("wal: %w", err)
	}

	s.Mem.Set(key, val)
	if s.Mem.Len() < s.maxElemsInMemory {
		return nil
	}

	return s.flushToSegment()
}

func (s *Store) Set(key string, val []byte) error {
	return s.set(key, segment.Value{Data: val})
}

func (s *Store) Del(key string) error {
	return s.set(key, segment.Value{IsTombstone: true})
}

func (s *Store) Close() error {
	s.walFD.Close()
	return nil
}
