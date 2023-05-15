package main

type stringInterner map[string]string

func (si stringInterner) Intern(s string) string {
	if interned, ok := si[s]; ok {
		return interned
	}
	si[s] = s
	return s
}

func main() {
}
