package main

import (
	"net/http"
	"time"
)

// 1. Basic
// 2. Add caching
// 3. Add caching with TTL
// 4. Add caching with TTL and size
// X. Stampede fix

func expensiveOp(path string) []byte {
	time.Sleep(time.Second)
	return []byte("boring")
}

func handler(w http.ResponseWriter, r *http.Request) {
	w.Write(expensiveOp(r.URL.Path))
}

func main() {
	http.ListenAndServe("localhost:8000", http.HandlerFunc(handler))
}
