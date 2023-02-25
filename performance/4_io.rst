* I/O and syscalls

    * Page cache
    * Filesystems (sync / flush cache)
    * direct I/O
    * buffered I/O
    * avoiding I/O (rmlint)
    * avoid copies (sendfile, hard/sym/reflinks -> git!)
    * Sparse files
    * DMA
    * Insane stuff: FIEMAP, fadvise
    * strace it!
    * eBPF for the really hard cases
    * IO scheduler in linux (ionice, how does it work?)
    * Cost of a syscall / what are syscalls? Userspace / Kernelspace


============


Make an example that shows the cost of a syscall:

- create big file:

    a) read it with many small read()
    b) read with large buffers
    c) read it with too large buffers

============


IO for a simple key value store:

1. simple append only write, get reads only the last value
   (terribly slow because get needs to scan the whole db)

   Can be implemented in two lines of bash.

2. Index needed!
   Store an in-memory hash table mapping keys to offsets
   Store data as log structured, append only file.
   When loading the database, the hash table gets reconstructed.
   When values get read, we can seek to the right position.

   This is already a DB on the market: Bitcask

3. This log file would grow a lot, making performance not optimal. Split it up
   in segments afer certain size! Compact old segment files. i.e. deduplicate
   keys or join several segments even. Can be easily done in the background.

4. How do we delete stuff? We write tombstones.


Advantage:

* Nice performance actually
* Very simple design an easy to debug.

Disadvantages:

* No range queries possible.
* All hash keys must fit in memory.



LSM (Log structured merge tree): Store keys in sorted order on disk (sorted by key)

-> Makes range queries possible
-> Not all keys need to fit in memory (memory index can be sparse, because we can use binary search)



Databases like Postgres use parts of this concept by using a WAL (write ahead log)
