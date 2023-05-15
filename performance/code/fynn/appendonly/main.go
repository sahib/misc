package main

// Very simple append-only key-value store in ~100 lines.
// It uses a simple binary format to store each entry.
//
// It could perform well if a lot of keys are written
// and updates to keys are seldom. Reading is not that
// efficient since it is sequential, no caching.
//
// There is plenty room for cpu & memory optimization
// and actual use would require a lot better error
// handling e.g. during database loading. One bad key
// would stop making the database loadable right now.

import (
	"encoding/binary"
	"errors"
	"fmt"
	"io"
	"os"
	"sync"
)

type Entry struct {
	Key string
	Val []byte
}

func (e *Entry) Bytes() []byte {
	b := make([]byte, 4+len(e.Key)+8+len(e.Val))

	// copy constant 4 byte size:
	binary.BigEndian.PutUint32(b[0:], uint32(len(e.Key)))
	off := 4

	// copy key contents:
	off += copy(b[off:], []byte(e.Key))

	// copy constant 8 byte size:
	binary.BigEndian.PutUint64(b[off:], uint64(len(e.Val)))
	off += 8

	// copy actual value:
	copy(b[off:], e.Val)
	return b
}

func FromBytes(r io.Reader) (*Entry, error) {
	var keySizeBuf [4]byte
	if _, err := io.ReadFull(r, keySizeBuf[:]); err != nil {
		return nil, err
	}

	keySize := binary.BigEndian.Uint32(keySizeBuf[:])
	key := make([]byte, keySize)
	if _, err := io.ReadFull(r, key[:]); err != nil {
		return nil, err
	}

	var valSizeBuf [8]byte
	if _, err := io.ReadFull(r, valSizeBuf[:]); err != nil {
		return nil, err
	}

	valSize := binary.BigEndian.Uint64(valSizeBuf[:])
	val := make([]byte, valSize)
	if _, err := io.ReadFull(r, val[:]); err != nil {
		return nil, err
	}

	return &Entry{Key: string(key), Val: val}, nil
}

type KV struct {
	mu      sync.Mutex
	fd      *os.File
	offsets map[string]int64
}

func NewKV(dbPath string) (*KV, error) {
	flags := os.O_APPEND | os.O_CREATE | os.O_RDWR
	fd, err := os.OpenFile(dbPath, flags, 0644)
	if err != nil {
		return nil, err
	}

	if _, err := fd.Seek(0, io.SeekStart); err != nil {
		return nil, err
	}

	offsets := make(map[string]int64)
	for {
		offset, _ := fd.Seek(0, io.SeekCurrent)
		entry, err := FromBytes(fd)
		if err == io.EOF || err == io.ErrUnexpectedEOF {
			break
		}

		if err != nil {
			return nil, err
		}

		offsets[entry.Key] = offset
	}

	return &KV{fd: fd, offsets: offsets}, nil
}

func (kv *KV) Close() error {
	kv.mu.Lock()
	defer kv.mu.Unlock()

	return kv.fd.Close()
}

func (kv *KV) Set(key string, val []byte) error {
	kv.mu.Lock()
	defer kv.mu.Unlock()

	entry := &Entry{Key: key, Val: val}
	data := entry.Bytes()
	_, err := kv.fd.Write(data)
	if err != nil {
		return err
	}

	// make sure the new key is also known to the offset table:
	offset, _ := fd.Seek(0, io.SeekCurrent)
	kv.offsets[key] = offset
	return nil
}

func (kv *KV) Get(key string) ([]byte, error) {
	kv.mu.Lock()
	defer kv.mu.Unlock()

	offset, ok := kv.offsets[key]
	if !ok {
		return nil, errors.New("no such key")
	}

	_, err := kv.fd.Seek(offset, io.SeekStart)
	if err != nil {
		return nil, err
	}

	entry, err := FromBytes(kv.fd)
	if err != nil {
		return nil, err
	}

	return entry.Val, nil
}

func main() {
	const dbPath = "db"

	kv1, err := NewKV("db")
	if err != nil {
		panic(err)
	}

	kv1.Set("key1", []byte("val1"))
	kv1.Set("key2", []byte("val2"))
	kv1.Close()

	kv2, err := NewKV("db")
	if err != nil {
		panic(err)
	}

	val1, err := kv2.Get("key1")
	if err != nil {
		panic(err)
	}

	fmt.Println(string(val1))

	val2, err := kv2.Get("key2")
	if err != nil {
		panic(err)
	}

	fmt.Println(string(val2))
}
