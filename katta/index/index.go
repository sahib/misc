package index

import "github.com/sahib/misc/katta/segment"

type Index struct {
}

// TODO: Implement bloom filter to quickly check if a key is present.
//       (to help skipping reading if we're sure it's not there,
//        false positive are tolerable therefore)
// TODO: Choose main data structure for index. Needs:
//       - Fast appending/insert. (max O(log n))
//       - Fast querying. (max O(log n))
// TODO: Implement knob or fine-tuning to control how sparse the index is.

// New returns an empty index.
func New() *Index {
	return &Index{}
}

func (i *Index) Insert(key string, segmentID segment.ID, offet segment.Off) {
}

// LikelyContains check if `key` is likely part of the kv-store.
// The index is sparse, which means it does not store all keys there
// are but only every 10th key. It does not know for sure if the keys
// in between are present, it just knows where they would be located.
// To make a quick decision if I/O is worth the trouble you can check
// if it is likely there. This might produce false positives.
func (i *Index) LikelyContains(key string) bool {
	return false
}

type Result struct {
	SegmentOff segment.Off
	SegmentID  segment.ID
}

// Lookup checks the index for the position of `key`.
// It returns the location where the key is stored by specifying
// a lower bound and an upper bound. The key might not be present
// in this range, as the index only tells you where you would find
// a key, not if it's there. See LikelyContains()
func (i *Index) Lookup(key string) (Result, Result) {
	return Result{}, Result{}
}
