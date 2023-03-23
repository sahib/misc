Performance Workshop
====================

Implement a Key-Value-Store.

Required features
-----------------

* ``Get(key []byte) ([]byte, error)`` returns the value for `key` and possible errors.
* ``Set(key, val []byte) error`` remembers `val` for `key` and returns possible errors.
* When ``Set(key, val)`` returns, a subsequent ``Get(key`` must immediately return the updated value.
* The store can remember more values than there is physical memory.
* The data must be stored persistently and loaded from disk on restart.

Other requirements
------------------

* You can use any language; compiled languages are recommended though.
* You can use any design; a basic LSM approach is recommended though.
* Deadline: TODO

Workshop-day tasks
------------------

CPU
###

1. Write benchmark to measure performance of get/set.
2. Profile your program using a profiler and identify benchmarks.
3. Try to fix at least one of those bottlenecks.
4. Run your benchmarks again and see if it improved.

Memory
######

1. Measure the amounts of allocation (allocs + amount)
2. See where the allocations come from and check how to reduce them.
3. Measure again.
4. Bonus: Until now all keys need to be held in memory: Is there a way to avoid this?

I/O
###

1. What kind of syscall does your program use? Can you identify them all?
2. Can you reduce the number of syscalls?
3. Measure the write throughput of your store on full load.
4. Make your DB crash at random points and see if all data is written (fsync!)

Parallel
########

1. Provide an async API for your KV-store.
2. Do the IO in background.
3. Queue up writes to the database.
4. Try to fetch keys in parallel.

Optional tasks for the motivated
--------------------------------

* Implement segment compression
* Implement ``Delete(key) error`` using tombstones.
* Make sure ``Get()`` performs well if the key does not exist.
* Implement ``Snapshot(w io.Writer) error`` which streams a **consistent
  copy** of the database to `w`.
* Implement efficient range queries ``O(log n)`` that can e.g. list the keys that
  start with ``DE`` and go no further than ``EN``.
