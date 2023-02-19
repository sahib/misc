package main

//go:noinline
func add(a, b int) int {
	return a + b
}

// func main() {
// 	add(2, 3)
// }

type Counter interface {
	StartAdding()
	Count() int64
}

type Counter1 struct {
	Count int
}
type Counter2 struct {
	Count int64
}

type Counter3 struct {
	Counts [8]int64
}

type paddedCounter struct {
	Count int64
	_     [64]byte
}
type Counter4 struct {
	Counts [8]int64
}

func main() {
}
