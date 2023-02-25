
* Nebenläufigkeit

    * concurrent vs parallel (python, node.js "parallelism")
    * Threads (Lightweight Processes) vs Processes
    * Goroutinen (Lightweight Threads)
    * Shared state (global state is always shared)
    * Mutex
    * Semaphore
    * Channel
    * Condition Variable
    * Pool
    * Exercise: Barrier (oder "Wait Group")
    * Atomic Operations (NOP NOP NOP...)
    * Race condition detection (helgrind, go -race, rust)


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


Dining Philosopher's problem as intro to synchronisation -> explain deadlock scenarios and how to debug them.
