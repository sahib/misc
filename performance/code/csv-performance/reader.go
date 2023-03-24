package main

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"strings"
)

const (
	delimiter = ","
)

func ReadCSVRowsV1(data []byte) ([]map[string]string, error) {
	headers := []string{}
	results := []map[string]string{}

	for idx, line := range strings.Split(string(data), "\n") {
		cells := strings.Split(line, delimiter)

		if idx == 0 {
			// first line, assume this is the header.
			for _, header := range cells {
				headers = append(headers, header)
			}

			continue
		}

		result := make(map[string]string)
		for idx, cell := range cells {
			result[headers[idx]] = cell
		}

		results = append(results, result)
	}

	return results, nil
}

////////

type CSVReaderV2 struct {
	scanner *bufio.Scanner
}

func NewCSVReaderV2(r io.Reader) *CSVReaderV2 {
	return &CSVReaderV2{
		scanner: bufio.NewScanner(r),
	}
}

func (r *CSVReaderV2) Record() ([]string, error) {
	if !r.scanner.Scan() {
		err := r.scanner.Err()
		if err == nil {
			err = io.EOF
		}
		return nil, err
	}

	line := r.scanner.Text()
	return strings.Split(line, delimiter), nil
}

///////

type CSVReaderV3 struct {
	scanner *bufio.Scanner
	fields  []string
}

func NewCSVReaderV3(r io.Reader) *CSVReaderV3 {
	return &CSVReaderV3{
		scanner: bufio.NewScanner(r),
	}
}

func splitInline(s string, delim byte, buf []string) {
	for {
		next := strings.IndexByte(s, delim)
		if next < 0 {
			next = len(s)
			buf[0] = s
			break
		}

		// hex, hex
		buf[0] = s[:next]
		buf = buf[1:]
		s = s[next+1:]
	}
}

func (r *CSVReaderV3) Record() ([]string, error) {
	if !r.scanner.Scan() {
		err := r.scanner.Err()
		if err == nil {
			err = io.EOF
		}
		return nil, err
	}

	line := r.scanner.Text()

	if r.fields == nil {
		// allocate number of fields through first line.
		fieldCount := strings.Count(line, delimiter) + 1
		r.fields = make([]string, fieldCount)
	}

	splitInline(line, delimiter[0], r.fields)
	return r.fields, nil
}

///////

type CSVReaderV4 struct {
	r      io.Reader
	buf    bytes.Buffer
	fields []string
}

func NewCSVReaderV4(r io.Reader) *CSVReaderV4 {
	return &CSVReaderV4{
		r: r,
	}
}

func splitInlineBytes(b []byte, delim byte, buf []string) {
	for {
		next := bytes.IndexByte(b, delim)
		if next < 0 {
			next = len(b)
			buf[0] = string(b) // allocation
			break
		}

		buf[0] = string(b[:next]) // allocation
		buf = buf[1:]
		b = b[next+1:]
	}
}

func (r *CSVReaderV4) Record() ([]string, error) {
	var line []byte
	var err error

	// TODO: Completely broken.
	for {
	}

	if err != nil && err != io.EOF {
		return nil, err
	} else if err != io.EOF {
		// line still contains delimiter:
		line = line[len(line)-1:]
	}

	fmt.Println("LINE", string(line))

	if r.fields == nil {
		// allocate number of fields through first line.
		fieldCount := bytes.Count(line, []byte(delimiter)) + 1
		r.fields = make([]string, fieldCount)
	}

	splitInlineBytes(line, byte(delimiter[0]), r.fields)
	return r.fields, err
}

func main() {
	fmt.Println("vim-go")
}
