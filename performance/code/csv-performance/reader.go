package main

// TODO: Mention http://thomasburette.com/blog/2014/05/25/so-you-want-to-write-your-own-CSV-code/
// TODO: Insert that into the debugging section: https://i.redd.it/6jswgg07hij81.jpg
// TODO: Explain flamegraph (as alternative representation)
// TODO: Steal pyramid from here: https://blog.alexellis.io/golang-e2e-testing-case-study/
// TODO: Integration vs Unit Tests: https://youtu.be/mC3KO47tuG0

// Fuzzing:
// TODO: https://jayconrod.com/posts/123/internals-of-go-s-new-fuzzing-system

// TODO: Test examples:
// Test all inputs:
// - easy for functions with limited inputs (bool, uint64)
// - the more inputs the worse it gets
// - strings are terrible (-> fuzzing!)
//
// -> Wie wählt man also interessante Test cases aus?
// -> Manual Testing vs Fuzzing
// -> Black-Box Tests (requirements prüfen) vs White-Box Tests (implementations details prüfen)
//    (Beispiel: Programmierer weiß dass das mit den migrations tricky zu implementieren war,
//     also schreibt er dafür viel tests. Andersrum: Wenn 20% des Codes 90% der Requirements
//     umsetzt, dann werden auch präferiert diese 20% getestet. Da die restlichen 80% Code
//     meist für Fehlerfälle und Edge-Cases ist fehlt dann hier oft was. Andererseits verliert
//     man sich als Programmierer auch oft in details und vergisst auch schon mal Requirements).
// -> Ziel: Möglichst viel Abdeckung mit möglichst wenig Testcases
//    (-> go coverage tool zeigen)
// -> Tipp: Tests möglichst so schreiben, dass man den gleichen Test code
//    für mehrere Implementierungen des gleichen Interfaces schreiben kann.
//    (Beispiel: Telemetry Queue).
// -> Tipp: Mehr Test Code = Mehr Maintenance. Kopiert man einen Test sehr oft,
//    dann muss man ihn auch sehr oft ändern wenn sich die anforderungen ändern.
//    DRY auch bei Tests
// -> Tipp: Tests möglichst parametrisieren. Table Driven Tests.

// special case: functions with side effects:
// - readUpdateMarker() (string, error)
//   -> Treat every environment mutation as
// - Tipp: State machines: State-übergänge aufzeichnen.
// - Tipp: Wenn ein Bug entdeckt wird, sollte man einen Regression-Test anfertigen,
//   um sicherzugehen dass dieser Bug nicht wieder kommt. Nichts ist peinlicher als den
//   gleichen Bug mehrfach in Production fixen zu müssen (Grüße an Subu!)
//
//
// Bisher: Fokus auf das Testen einzelner Komponenten: Unit-Test.
// Integration-Tests:
// End-To-End Tests:
// Smoke Tests:
// Regression Tests:
//
// Performance Lecture: splice() (or the cost of syscalls)

// Auf Systeme wie Ada eingehen:
// -> Anreicherung des Quellcodes mit Spezifikationen
// -> Compiler testet automatisch ob das Programm die Spezifikation einhält.
// -> Warum wir das nicht verwenden?

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
