package main

// Pure in-memory key value store with primitive load and sync
// that can only load or sync all keys and values at the same time.
//
// As stupid as it is, this can be a viable solution if you have to
// save the keys only very seldomly and load them only once per run.
// Also, you should have not more key/values as memory and should not
// require transactions, range queries or anything fancy.

import (
	"bytes"
	"fmt"
	"io/ioutil"
)

type KV struct {
	m map[string][]byte
}

func (kv *KV) sync(dbPath string) error {
	var b bytes.Buffer
	for k, v := range kv.m {
		b.WriteString(fmt.Sprintf("%s=%s\n", k, v))
	}

	// NOTE: This should not directly overwrite the db file
	// but write a temporary file right beside it and move it over
	// since this would be atomically. Left out for lazyness.
	return ioutil.WriteFile(dbPath, b.Bytes(), 0644)
}

func load(dbPath string) (*KV, error) {
	data, err := ioutil.ReadFile(dbPath)
	if err != nil {
		return nil, err
	}

	m := make(map[string][]byte)
	for _, line := range bytes.Split(data, []byte("\n")) {
		split := bytes.SplitN(line, []byte("="), 2)
		if len(split) < 2 {
			continue
		}

		m[string(split[0])] = split[1]
	}

	return &KV{m: m}, nil
}

func main() {
	const dbPath = "db"

	kv1 := &KV{m: make(map[string][]byte)}
	kv1.m["key1"] = []byte("val1")
	kv1.m["key2"] = []byte("val2")
	kv1.sync(dbPath)

	kv2, err := load(dbPath)
	if err != nil {
		panic(err)
	}
	fmt.Println(string(kv2.m["key1"]))
	fmt.Println(string(kv2.m["key2"]))
}
