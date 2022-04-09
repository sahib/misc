package main

import (
	"bytes"
	"encoding/csv"
	"fmt"
	"io"
	"io/ioutil"
	"strconv"
	"testing"

	"github.com/stretchr/testify/require"
)

type csvDummyGenerator struct {
	nRows    int
	nCols    int
	rowCount int
	buf      *bytes.Buffer
}

const (
	alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
)

// indexToHeaderName generates header names in the form:
// A, B, C [...], AA, AB, AC
func indexToHeaderName(idx int) string {
	runes := make([]rune, idx/len(alphabet)+1)
	for runeIdx := len(runes) - 1; runeIdx >= 0 && idx > 0; runeIdx-- {
		runes[runeIdx] = rune(alphabet[idx%len(alphabet)])
		idx /= len(alphabet)
		idx--
	}

	return string(runes)
}

func (cdg csvDummyGenerator) Read(buf []byte) (int, error) {
	// If not enough dummy data is there, generate enough so
	// we can fill the incoming `buf`.
	for cdg.buf.Len() < len(buf) {
		if cdg.rowCount >= cdg.nRows {
			n, _ := cdg.buf.Read(buf)
			return n, io.EOF
		}

		for idx := 0; idx < cdg.nCols; idx++ {
			if cdg.rowCount == 0 {
				// write header:
				cdg.buf.WriteString(indexToHeaderName(idx))
			} else {
				// write data:
				cdg.buf.WriteString(strconv.FormatInt(int64(idx), 10))
			}

			if idx != cdg.nCols-1 {
				cdg.buf.WriteString(",")
			} else {
				cdg.buf.WriteString("\n")
			}
		}

		cdg.rowCount++
	}

	return cdg.buf.Read(buf)
}

func generateCSV(nRows, nCols int) io.Reader {
	return csvDummyGenerator{
		nRows: nRows,
		nCols: nCols,
		buf:   bytes.NewBuffer(nil),
	}
}

func TestReader(t *testing.T) {
	nRowTests := []int{0, 1, 10, 200, 4000}
	nColTests := []int{0, 1, 10, 200, 4000}

	for _, nRows := range nRowTests {
		t.Run(fmt.Sprintf("%d-rows", nRows), func(t *testing.T) {
			for _, nCols := range nColTests {
				t.Run(fmt.Sprintf("%d-cols", nCols), func(t *testing.T) {
					data, err := ioutil.ReadAll(generateCSV(nRows, nCols))
					require.NoError(t, err)

					rows, err := ReadCSVRowsV1(data)
					require.NoError(t, err)

					for _, row := range rows {
						fmt.Println(row)
					}
				})
			}
		})
	}

}

func benchmarkReaderV1(b *testing.B, nRows, nCols int) {
	data, err := ioutil.ReadAll(generateCSV(nRows, nCols))
	require.NoError(b, err)

	b.ResetTimer()
	for n := 0; n < b.N; n++ {
		_, err = ReadCSVRowsV1(data)
		require.NoError(b, err)
	}
}

func benchmarkReaderV2(b *testing.B, nRows, nCols int) {
	for n := 0; n < b.N; n++ {
		b.StopTimer()
		r := NewCSVReaderV2(generateCSV(nRows, nCols))
		b.StartTimer()

		for {
			if _, err := r.Record(); err != nil {
				break
			}
		}
	}
}

func benchmarkReaderV3(b *testing.B, nRows, nCols int) {
	for n := 0; n < b.N; n++ {
		b.StopTimer()
		r := NewCSVReaderV3(generateCSV(nRows, nCols))
		b.StartTimer()

		for {
			if _, err := r.Record(); err != nil {
				break
			}
		}
	}
}

func benchmarkReaderV4(b *testing.B, nRows, nCols int) {
	for n := 0; n < b.N; n++ {
		b.StopTimer()
		r := NewCSVReaderV4(generateCSV(nRows, nCols))
		b.StartTimer()

		for {
			if _, err := r.Record(); err != nil {
				break
			}
		}
	}
}

func benchmarkReaderStdlib(b *testing.B, nRows, nCols int) {
	for n := 0; n < b.N; n++ {
		b.StopTimer()
		r := csv.NewReader(generateCSV(nRows, nCols))
		b.StartTimer()

		for {
			if _, err := r.Read(); err != nil {
				break
			}
		}
	}
}

func BenchmarkReader(b *testing.B) {
	nRowTests := []int{10}
	nColTests := []int{10, 100}
	benchmarks := []struct {
		name string
		fn   func(b *testing.B, nRows, nCols int)
	}{
		{"v1", benchmarkReaderV1},
		{"v2", benchmarkReaderV2},
		{"v3", benchmarkReaderV3},
		{"v4", benchmarkReaderV4},
		{"stdlib", benchmarkReaderStdlib},
	}

	for _, bench := range benchmarks {
		for _, nRows := range nRowTests {
			for _, nCols := range nColTests {
				b.Run(fmt.Sprintf("%s-%d-rows-%d-cols", bench.name, nRows, nCols), func(b *testing.B) {
					bench.fn(b, nRows, nCols)
				})
			}
		}
	}
}
