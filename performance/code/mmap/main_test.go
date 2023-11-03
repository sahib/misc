package main

import (
	"math"
	"os"
	"path/filepath"
	"testing"
)

const N = 10000

type Log interface {
	Append(num uint64) error
	Pop() (uint64, error)
	Close() error
}

type Testable interface {
	Fatalf(fmt string, args ...any)
}

func TestMmapLog(t *testing.T) {
	testMmapLog(t)
}

func testMmapLog(t Testable) {
	testLog(t, func(path string) Log {
		log, err := OpenMmapLog(path, N*8)
		if err != nil {
			t.Fatalf("failed to create log: %v", err)
		}

		return log
	})
}

func TestFileLog(t *testing.T) {
	testFileLog(t)
}

func testFileLog(t Testable) {
	testLog(t, func(path string) Log {
		log, err := OpenFileLog(path)
		if err != nil {
			t.Fatalf("failed to create log: %v", err)
		}

		return log
	})
}

func testLog(t Testable, open func(path string) Log) {
	tmpDir, err := os.MkdirTemp("", "log-test")
	if err != nil {
		t.Fatalf("failed to create temp dir: %v", err)
	}
	defer os.RemoveAll(tmpDir)

	logPath := filepath.Join(tmpDir, "log")
	log := open(logPath)

	for idx := 0; idx < N; idx++ {
		if err := log.Append(math.MaxUint64 - uint64(idx)); err != nil {
			t.Fatalf("failed to append: %v", err)
		}
	}

	for idx := 0; idx < N; idx++ {
		num, err := log.Pop()
		if err != nil {
			t.Fatalf("failed to pop: %v", err)
		}

		if num != math.MaxUint64-uint64(idx) {
			t.Fatalf("wrong number %d at %d", num, idx)
		}
	}

	log.Close()
}

func BenchmarkMmapLog(b *testing.B) {
	for n := 0; n < b.N; n++ {
		testMmapLog(b)
	}
}

func BenchmarkFileLog(b *testing.B) {
	for n := 0; n < b.N; n++ {
		testFileLog(b)
	}
}
