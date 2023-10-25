package main

import (
	"compress/gzip"
	"io"
	"os"
	"sync"
)

var writerGzipPool = sync.Pool{
	New: func() interface{} {
		return gzip.NewWriter(io.Discard)
	},
}

func compressWithPool(r io.Reader) {
	writer := writerGzipPool.Get().(*gzip.Writer)
	writer.Reset(io.Discard)
	io.Copy(writer, r)
	writer.Flush()
	writerGzipPool.Put(writer)
}

func compressWithoutPool(r io.Reader) {
	gzipw := gzip.NewWriter(io.Discard)
	io.Copy(gzipw, r)
	gzipw.Flush()
}

func main() {
	compressWithPool(os.Stdin)
}
