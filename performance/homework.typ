#set text(
    font: "Linux Libertine",
    size: 10pt
)
#set page(
    paper: "a4"
)

#align(center)[
    _»What I cannot create, I do not understand«_

    -- Richard Feymann
]

#let go(text) = {
    raw(text, lang: "go")
}


= Performance Workshop Homework

Implement your very own Key-Value-Store in a programming language of your
choice. While you can of course code it in Bash, SQL or even Brainfuck, for
best learning effect, a compiled language is _recommended_. The internal design
of your store can be whatever you like it to be as long it fulfills the
requirements below. A basic LSM (Log-Structured-Merge-Tree), as discussed in
the introductionary slides, is a good and performant choice though.

_Deadline:_ You should prepare a basic prototype until the first workshop
about CPU internals. After every workshop today you should have some ideas how
to extend or improve your implementation.
Try to see if you can incorparate some knowledge from the slides into your implementation:

#align(center)[
    https://sahib.github.io/misc/performance/slides/0_toc/index.html
]

== Required minimal feature set

+ »#go("Get(key []byte) ([]byte, error)")« returns the value for `key` and possible errors.
+ »#go("Set(key, val []byte) error")« remembers `val` for `key` and returns possible errors.
+ When #go("Set(key, val)") returns, a subsequent #go("Get(key)") must immediately return the updated value.
+ The store can remember more values than there is physical memory.
+ The data must be stored persistently and loaded from disk on restart.

=== CPU Tasks:

+ Write benchmarks to measure performance of #go("Get()") & #go("Set()")
+ Profile your program using a profiler and identify bottlenecks.
+ Try to fix at least one of those bottlenecks.
+ Run your benchmarks again and see if it improved.

=== Memory Tasks:

+ Measure the number and amount of allocation.
+ See where the allocations come from and check if you can reduce them.
+ Measure again and repeat until you identified most allocations.
+ Bonus: Implement a sorted index to lower the number of keys you can keep in memory.

=== I/O & Syscalls Tasks:

+ What kind of syscall does your program use? Can you identify them all?
+ Can you reduce the number of syscalls or use more efficient ones?
+ Measure the write throughput and latency of your store on full load. (#go("Get()") & #go("Set()"))
+ Make your DB crash at random points and see if all data is written (#go("fsync()"))

=== Concurrency Tasks:

+ Provide an asynchronous API for your store so users do not block.
+ Implement (segment) compression, with background I/O.
+ Do the IO in background.
+ Queue up writes to the database.
+ Try to fetch keys in parallel.

=== Optional tasks for the motivated:

+ Implement segment compression
+ Implement »#go("Delete(key) error")« using tombstones.
+ Make sure #go("Get()") performs well if the key does _not_ exist.
+ Implement transactions (write several values or none at all).
+ Implement »#go("Snapshot(w io.Writer) error")«, which streams a _consistent
  copy_ of the database to `w` (which might be stdout or a file or a socket...). This can be used as backup.
+ Implement efficient range queries ($O(log n)$) that can list all keys with a certain prefix
  (i.e. _Pat_ matches _Patrick_, _Patricia_, _Pathological_, ...)
