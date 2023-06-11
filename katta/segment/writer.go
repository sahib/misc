package segment

type Writer struct {
}

func NewWriter(id ID) *Writer {
	// TODO: check that id does not exist yet!
	return nil
}

func (w *Writer) Write(key string, value []byte) error {
	return nil
}

func (w *Writer) Tombstone(key string) error {
	return nil
}

func (w *Writer) Close() error {
	return nil
}
