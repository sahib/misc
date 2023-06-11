package kv

type InMem struct {
}

func NewInMem() *InMem {
	return &InMem{}
}

func (i *InMem) Get(key string) []byte {
	return nil
}

func (i *InMem) Set(key string, val []byte) {
}

func (i *InMem) Del(key string) {
}
