package wal

type Reader struct {
}

// TODO: Can Reader and Writer be used at the same time?

func OpenReader(path string) (*Reader, error) {
	return nil, nil
}

func (r *Reader) Next() bool {
	return false
}

func (r *Reader) Key() string {
	return ""
}

func (r *Reader) Value() []byte {
	return nil
}
