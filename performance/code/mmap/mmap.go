package main

import (
	"encoding/binary"
	"errors"
	"fmt"
	"io"
	"os"

	"golang.org/x/sys/unix"
)

type MmapLog struct {
	path     string
	fd       *os.File
	mmap     []byte
	size     int64
	readOff  int64
	writeOff int64
}

func OpenMmapLog(path string, size int64) (*MmapLog, error) {
	l := &MmapLog{path: path}

	flags := os.O_APPEND | os.O_CREATE | os.O_RDWR
	fd, err := os.OpenFile(l.path, flags, 0600)
	if err != nil {
		return nil, fmt.Errorf("log: open: %w", err)
	}

	if err := fd.Truncate(size); err != nil {
		return nil, fmt.Errorf("truncate: %w", err)
	}

	mmap, err := unix.Mmap(
		int(fd.Fd()),
		0,
		int(size),
		unix.PROT_READ|unix.PROT_WRITE,
		unix.MAP_SHARED_VALIDATE,
	)

	if err != nil {
		fd.Close()
		return nil, fmt.Errorf("log: mmap: %w", err)
	}

	// give OS a hint that we will likely need that memory soon:
	_ = unix.Madvise(mmap, unix.MADV_WILLNEED)

	l.size = size
	l.fd = fd
	l.mmap = mmap
	return l, nil
}

func (l *MmapLog) Append(num uint64) error {
	if l.writeOff+8 > l.size {
		return fmt.Errorf("exceeds size: %d > %d", l.writeOff+8, l.size)
	}

	binary.BigEndian.PutUint64(l.mmap[l.writeOff:], num)
	l.writeOff += 8
	return nil
}

func (l *MmapLog) Pop() (uint64, error) {
	if l.readOff-8 > l.size {
		return 0, io.EOF
	}

	num := binary.BigEndian.Uint64(l.mmap[l.readOff+0:])
	l.readOff += 8
	return num, nil
}

func (l *MmapLog) Close() error {
	syncErr := unix.Msync(l.mmap, unix.MS_SYNC)
	unmapErr := unix.Munmap(l.mmap)
	closeErr := l.fd.Close()
	return errors.Join(syncErr, unmapErr, closeErr)
}
