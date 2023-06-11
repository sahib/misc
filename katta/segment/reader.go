package segment

type Reader struct {
}

func (r *Reader) ID() ID {
	return 0
}

func (r *Reader) Next() bool {
	return false
}

func (r *Reader) Seek(off Off) error {
	return nil
}

func (r *Reader) Key() string {
	return ""
}

func (r *Reader) Value() []byte {
	return nil
}

func (r *Reader) Off() Off {
	return 0
}
