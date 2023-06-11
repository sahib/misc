package wal

type Writer struct {
}

func OpenWriter(path string) (*Writer, error) {
	return nil, nil
}

func (w *Writer) Append(key string, val []byte) error {
	return nil
}

func (w *Writer) Close() error {
	return nil
}
