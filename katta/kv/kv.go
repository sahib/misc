package kv

// NOTE: High level TODOs:
// TODO: Make wal reader seekable.
// TODO: Convert btree.Map to segment.
// TODO: Implement merge functionality.

import (
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"

	"github.com/sahib/misc/katta/segment"
	"github.com/sahib/misc/katta/wal"
	"github.com/tidwall/btree"
)

var (
	ErrKeyNotFound = errors.New("no such key")
)

type value struct {
	IsTombstone bool
	Data        []byte
}

type Store struct {
	Registry *segment.Registry
	WAL      *wal.Writer
	Mem      *btree.Map[string, value]

	walFD io.WriteCloser

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
		os.O_TRUNC|os.O_WRONLY|os.O_CREATE,
		0600,
	)
	if err != nil {
		return nil, fmt.Errorf("wal: open: %w", err)
	}

	return &Store{
		Registry:         reg,
		Mem:              &btree.Map[string, value]{},
		WAL:              wal.NewWriter(walFD),
		walFD:            walFD,
		maxElemsInMemory: opts.MaxElemsInMemory,
	}, nil
}

func (s *Store) Get(key string) ([]byte, error) {
	if v, ok := s.Mem.Get(key); ok {
		if v.IsTombstone {
			// was explicitly deleted.
			return nil, ErrKeyNotFound
		}

		return v.Data, nil
	}

	for _, segment := range s.Registry.List() {
		lo, hi := segment.Index().Lookup(key)
		r, err := segment.Reader()
		if err != nil {
			return nil, fmt.Errorf("read: %w", err)
		}

		if err := r.Seek(lo); err != nil {
			return nil, fmt.Errorf("seek: %w", err)
		}

		for r.Next() && r.Pos() < hi {
			if r.Key() == key {
				if r.IsTombstone() {
					return nil, ErrKeyNotFound
				}

				return r.Val(), nil
			}
		}

		if err := r.Err(); err != nil {
			return nil, fmt.Errorf("read: %w", err)
		}
	}

	return nil, ErrKeyNotFound
}

func (s *Store) clearMemtable() error {
	seg := s.Registry.NewSegment()
	if err := s.Mem.WriteToSegment(seg.Writer()); err != nil {
		return err
	}

	// Clear old memtable and start fresh:
	s.Mem = &btree.Map[string, value]{}
	return nil
}

func (s *Store) set(key string, val value) error {
	// TODO: Make a proper distinction between tombstones here.
	if err := s.WAL.Append(key, val.Data); err != nil {
		return fmt.Errorf("wal: %w", err)
	}

	s.Mem.Set(key, val)
	if s.Mem.Len() < s.maxElemsInMemory {
		return nil
	}

	return s.clearMemtable()
}

func (s *Store) Set(key string, val []byte) error {
	return s.set(key, value{Data: val})
}

func (s *Store) Del(key string) error {
	return s.set(key, value{IsTombstone: true})
}

func (s *Store) Close() error {
	s.walFD.Close()
	return nil
}
