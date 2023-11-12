package main

type Item struct {
	Key  int64
	Blob []byte
}

func (i Item) Copy() Item {
	blob := make([]byte, len(i.Blob))
	copy(blob, i.Blob)
	return Item{Key: i.Key, Blob: blob}
}

type Items []Item

func (items Items) Copy() Items {
	copyItems := Items{}
	for _, item := range items {
		copyItems = append(copyItems, item.Copy())
	}
	return copyItems
}

func (items Items) CopyPrealloc() Items {
	copyItems := make(Items, 0, len(items))
	for _, item := range items {
		copyItems = append(copyItems, item.Copy())
	}
	return copyItems
}

func (items Items) CopyOptimized() Items {
	var size int
	for _, item := range items {
		size += len(item.Blob)
	}

	mem := make([]byte, size)

	copyItems := make(Items, 0, len(items))
	for _, item := range items {
		copy(mem, item.Blob)
		copyItems = append(copyItems, Item{
			Key:  item.Key,
			Blob: mem[:len(item.Blob)],
		})
		mem = mem[len(item.Blob):]
	}
	return copyItems
}
