package main

func main() {
}

type Store struct {
	kv map[string]int64
}

func (s *Store) Get(key []byte) ([]byte, error) {
	// Read offset, read from disk.
	return nil, nil
}

func (s *Store) Set(key, val []byte) error {
	// Write to append-only log.
	return nil
}

func (s *Store) rebalance() {
}
