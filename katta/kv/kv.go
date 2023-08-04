package kv

import (
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"

	"github.com/sahib/misc/katta/segment"
	"github.com/sahib/misc/katta/wal"
)

var (
	ErrKeyNotFound = errors.New("no such key")
)

type Store struct {
	Registry *segment.Registry
	WAL      *wal.Writer
	Mem      *Memtable

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
		Mem:              NewMemtable(),
		WAL:              wal.NewWriter(walFD),
		walFD:            walFD,
		maxElemsInMemory: opts.MaxElemsInMemory,
	}, nil
}

func (s *Store) Get(key string) ([]byte, error) {
	if v := s.Mem.Get(key); v != nil {
		return v, nil
	}

	for _, segment := range s.Registry.List() {
		lo, hi := segment.Index().Lookup(key)
		r := segment.Reader()
		if err := r.Seek(lo); err != nil {
			return nil, fmt.Errorf("seek: %w", err)
		}

		for r.Next() && r.Pos() < hi {
			if r.Key() == key {
				val, isTomb := r.Value()
				if !isTomb {
					return nil, ErrKeyNotFound
				}

				return val, nil
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
	s.Mem = NewMemtable()
	return nil
}

func (s *Store) Set(key string, val []byte) error {
	if err := s.WAL.Append(key, val); err != nil {
		return fmt.Errorf("wal: %w", err)
	}

	s.Mem.Set(key, val)
	if s.Mem.Size() < s.maxElemsInMemory {
		return nil
	}

	return s.clearMemtable()
}

func (s *Store) Del(key string) error {
	if err := s.WAL.AppendTombstone(key); err != nil {
		return fmt.Errorf("wal: %w", err)
	}

	s.Mem.Del(key)

	// TODO: Also add this to a segment? The latest one? Which?
	//       or add it to the mem index and write it later?
	//       also trigger mem table swap here?
	return nil
}

func (s *Store) Close() error {
	s.walFD.Close()
	return nil
}
