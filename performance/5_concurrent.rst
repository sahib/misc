
Parallel programming
====================

The art of distributing work so that we maximize
the number of used CPU cores with minimal overhead.

.. note::

   There are two ways to be comfortable writing parallel code:

   * Being very experienced and having made a lot of mistakes.
   * Being fearless and not be aware of the possible problems.

----

Concurrent vs Parallel
======================

Please define it.

.. note::

    Concurrent = execution might be interrupted at an time.
    Parallel = several instructions get executed at the same time.

----

What are processes?
===================

- Processes are a lightweight way to schedule work over all available cpu cores.
- Processes get started by ``fork()`` (except the first one...)
- Processes focus on memory isolation - memory can only be shared via IPC (unix sockets, pipes, shared memory, ...)
- Processes have their own ID (PID)

----

What are threads?
=================

- Threads are lightweight processes (huh?)
- Threads get started by ``pthread_create()``
- Threads share the heap of the process but have each their own stack
- Threads have their own ID (TID)

.. note::

   Threads are scheduled like processes by the kernel. No real difference is made between
   processes and threads in that regard.

----

What are coroutines?
====================

- Coroutines are lightweight threads (oh come on)
- Coroutines are implemented completely in user space using a scheduler
- Every detail depends on the individual programming languages' implementation
- Goroutines are one example of a coroutine implementation. Fibers are another often used term.

.. note::

   Good example of software evolution. Old concepts are never cleaned up. Just new concepts
   get added that enhance (in the best case) the old concepts. I call this toilet paper development:
   If it stinks, put another layer over it.

TODO: Make diagram showing the difference here.

----

Synchronization primitives
==========================

Threads & coroutines need to be in sync.

Big toolset of possible ways to do so.

.. note::

   If you use processes you obviously need to synchronize too sometimes.
   Potential ways can be to use filesystem locks or mlock() on shared memory.

   If not used they can be a hell to debug. Debuggers won't work and prints
   might change timings so deadlocks or race conditions might not always occur.

----

Primitive: Sleep
================

Just kidding. Don't!

----

Primitive: Semaphor
====================

.. note::

    A bouncer before a club.
    It's corona times and he knows that only 10 people may be in the club (sad times)
    He counts up when he let's somebody in and counts down when someone leaves.
    If the club is full new visitors have to wait

----

Primitive: Mutex
=================

A binary semaphore.

----

Primitive: Barrier (latch, wait group)
=======================================

An inverted semaphore

.. note::

   All threads have to arrive a certain point before any can continue.

Dining Philosopher's problem as intro to synchronisation -> explain deadlock scenarios and how to debug them.

----

Primitive: Condition variable
=============================

* Broadcast or notify a single thread.

.. note::

   Seldomly used in Go, but has their use cases.
   TODO: grep for usage in firmware / backend.

----

Primitive: Atomics
==================

* Store
* Load
* Increment
* Swap
* Compare-And-Swap

.. note::

   Several atomic operations are not atomic of course!

----

Primitive: Channel
==================

.. code-block:: go

   // buffered channel with 10 items
   c := make(chan int, 10)
   c <- 1 // send
   fmt.Println(<-c) // recv

.. note::

    Might be called prioq or something in other languages.
    Basically a slice or linked list protected with a mutex.

    Channels can be buffered or unbuffered:

    * unbuffered: reads and writes block until the other end is ready.
    * buffer: blocks only when channel is full.

    Channels can be closed, which can be used as signal to stop.
    A send to a closed channel panics.
    A recv from a closed channel blocks forever.

    We will see channels later in action.

----

Pattern: Pool
=============

Classical producer-consumer problem.

1. Start a limited number of goroutines.
2. Pass each a shared channel.
3. Let each goroutine receive on the channel.
4. Producer sends jobs over the channel.
5. Tasks are distributed over the go routines.

----

Pattern: Limiter
================

.. code-block:: go

    tokens := make(chan bool, 10)
    for i := 0; i < cap(tokens); i++ {
        tokens <- i
    }
    for _, job := range jobs {
        <-tokens
        go func(job Job) {
            // ... do work ...
            tokens <- true
        }(job)
    }

.. note::

   Very easy way to limit the number of go routines.
   Basically a lightweight pool - good for one-time jobs.

----

Pattern: Pipeline
=================

Several pools connected over channels.

.. code-block:: go

    // DO NOT:
    func work() {
        report := generateReport()
        encoded := report.Marshal()
        compressed := compress(encoded)
        sendToNSA(compressed)
    }

.. note::

   Talk about the naive implementation where time of finish will
   be influenced by a single long running job.


----

Problem: Shared state
=====================

.. note::

   Easiest solution: Communicate via copies, do not share memory.

----

Problem: Race conditions
========================

TODO: Race condition detection (helgrind, go -race, rust)

----

Problem: Deadlocks
==================

TODO

----

Problem: Livelock
=================

TODO

----

Problem: Resource starvation
============================

TODO

----

Brainfuck time
==============

.. image:: images/philosophers.png

* Each philosopher changes state between "thinking" and "eating".
* During "eating" he requires two forks (it's spaghetti)
* The state changes happend randomly after some time.

Goal: no philosopher should starve.

.. note::

   Two problems that can occur:

   * Deadlock: Every philosopher took the left fork. None can pick the right fork.
   * Starvation: A single philspopher might be unlucky and never get two forks.

   Solution:

   * Simple: Use a single mutex as "waiter" to stop concurrency.
   * Hard & correct: Use global mutex pluse "hungry" state with semaphor per philosopher.
   * Easier: Give philosophers invdividual rights and priorities.
   * Weird: philosopher talk to each other if they need a fork (i.e. channels)

----

Homework
========

1. Provide an async API for your KV-store.
2. Do the IO in background
2. Queue up writes to the database.
3. Try to fetch keys in parallel.
