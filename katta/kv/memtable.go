package kv

import (
	"github.com/sahib/misc/katta/segment"
	"github.com/tidwall/btree"
)

type Memtable struct {
	mem *btree.Map[string, []byte]
}

func NewMemtable() *Memtable {
	return &Memtable{}
}

func (i *Memtable) Get(key string) []byte {
	v, _ := i.mem.Get(key)
	return v
}

func (i *Memtable) Set(key string, val []byte) {
}

func (i *Memtable) Del(key string) {
}

func (i *Memtable) Size() int {
	return 0
}

func (i *Memtable) WriteToSegment(w *segment.Writer) error {
	return nil
}
