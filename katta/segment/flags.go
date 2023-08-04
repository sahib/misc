package segment

type EntryFlags uint32

const (
	EntryFlagTombstone = 1 << iota
	EntryFlagCompressionS2
)
