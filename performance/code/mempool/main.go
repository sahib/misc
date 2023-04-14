package main

import (
	"compress/gzip"
	"io"
	"io/ioutil"
	"os"
	"sync"
)

type Blub struct {
	A int `json:"a,omitempty"`
}

func (blub *Blub) Read(p []byte) (n int, err error) {
	var a int
	panic("not implemented") // TODO: Implement
}

var writerGzipPool = sync.Pool{
	New: func() interface{} {
		return gzip.NewWriter(ioutil.Discard)
	},
}

func compressWithPool(r io.Reader) {
	writer := writerGzipPool.Get().(*gzip.Writer)
	writer.Flush()
	io.Copy(writer, r)
	writerGzipPool.Put(writer)
}

func compressWithoutPool(r io.Reader) {
	gzipw := gzip.NewWriter(ioutil.Discard)
	io.Copy(gzipw, r)
}

func main() {
	compressWithPool(os.Stdin)
}
