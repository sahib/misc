package kv

import (
	"github.com/sahib/misc/katta/index"
	"github.com/sahib/misc/katta/segment"
	"github.com/sahib/misc/katta/wal"
)

type Store struct {
	Registry *segment.Registry
	WAL      *wal.Writer
	Index    *index.Index
	InMem    *InMem
}

type Options struct {
	// TODO: Pack some memory related options here.
}

func Open(dir string, opt Options) (*Store, error) {
	return nil, nil
}

func (s *Store) Get(key string) []byte {
	return nil
}

func (s *Store) Set(key string, val []byte) {
}

func (s *Store) Del(key string) {
}

func (s *Store) Close() error {
	return nil
}
