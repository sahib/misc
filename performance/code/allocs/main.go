package main

// imagine someStruct has also some other members
type someStruct struct {
	Total    int
	LenTotal int
}

//go:noinline
func wordcount(ws []string) map[string]someStruct {
	m := make(map[string]someStruct)
	for _, w := range ws {
		s, ok := m[w]
		if !ok {
			s = someStruct{}
		}

		s.Total += 1
		s.LenTotal += len(w)
		m[w] = s
	}

	return m
}

//go:noinline
func wordcountPtr(ws []string) map[string]*someStruct {
	m := make(map[string]*someStruct)
	for _, w := range ws {
		s, ok := m[w]
		if !ok {
			s = &someStruct{}
		}

		s.Total += 1
		s.LenTotal += len(w)
		m[w] = s
	}

	return m
}

func main() {

}
