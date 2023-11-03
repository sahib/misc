package main

import (
	"encoding/binary"
	"fmt"
	"io"
	"os"
)

type FileLog struct {
	fd      *os.File
	readOff int64
}

func OpenFileLog(path string) (*FileLog, error) {
	flags := os.O_APPEND | os.O_CREATE | os.O_RDWR
	fd, err := os.OpenFile(path, flags, 0600)
	if err != nil {
		return nil, fmt.Errorf("file-log: open: %w", err)
	}

	return &FileLog{fd: fd}, nil
}

func (fl *FileLog) Append(num uint64) error {
	var buf [8]byte
	binary.BigEndian.PutUint64(buf[:], num)
	_, err := fl.fd.Write(buf[:])
	return err
}

func (fl *FileLog) Pop() (uint64, error) {
	if _, err := fl.fd.Seek(fl.readOff, io.SeekStart); err != nil {
		return 0, err
	}

	var buf [8]byte
	if _, err := io.ReadFull(fl.fd, buf[:]); err != nil {
		return 0, err
	}

	fl.readOff += 8
	return binary.BigEndian.Uint64(buf[:]), nil
}

func (fl *FileLog) Close() error {
	return fl.fd.Close()
}
