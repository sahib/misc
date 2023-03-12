General idea:

* Teaching you about the internals of program execution.
* Very neglected field - not much teached in studies, during day-to-day work "it worked (once)" is more important.
* Maybe you heard of Moore's law?
* Andy and Bill's law: What Andy (Intel ex-CEO) produces in Hardware speed, Bill Gates takes away.
* Lemur's law: Software engineers get twice as incompentent every decade (only half ironic) - seriously, as an engineering discipline we should be
  ashamed of how bad we performed over the last decades. We introduced so many layers of bad software and hacks that we depend on that we can't
  change anymore. It's like building a complete city on sand. Part of this because we don't really do engineerings and focus so much on providing
  company value that many of us did not even learn how good, performance optimized is supposed to look like. The costs of software engineers
  is more expensive than hardware these days, but this is short sighted. Investing in quality long term benefits us all.
  I hope to change your perspective a bit in this talk. We all lost the connection to the machine our programs run on and while the things in this
  talk were somewhat common knowledge 20 years ago (at least parts of it) it became somehow obscure knowledge over time and universities just focused
  on disciplines like web development and data science where you're not supposed to have this knowledge. Because you know, numpy and pandas does it for you.
  Or the browser will just do the right thing.
* In the 90s we still squeezed every byte of memory out of game consoles and did both amazing and scary optimizations to get basic functionality.
* And last decade we invented things like Electron, a lazy-ass way to make applications "portable" by just starting a browser for every application - I don't want you guys to invent something like Electron
* If you think Electron is a good idea, then please stop doing anything related to software engineering.
* Maybe have a try with gardening, or do waterboarding in Guantanamo. Just do something less hurtful to mankind than Electron
* Seriously take some pride as software engineerings and try to leave a solid legacy to the next generation of engineers.

Disclaimer:

* We're working from low level to slightly higher level here. Don't expect tips like "use this data structure to make
  stuff incredibly fast". I'll won't go over all possible performance tips for your language (there are better
  lists on the internet). I also won't go over a lot of data structures - what I do show is to show you how to choose
  a data structure.
* The talk is loosely tied to the hardware: General intro, cpu, mem, io, parallel programming
* Most code examples will be in Go and C, as most ideads require a compiled language.
* Interpreted languages like Python/Typescript might take away a few concepts, but to be honest,
  your language is fucked up and will never achieve solid performance.
* For Python you can at least put performance criticals into C libraries, for the blistering cestpool
  that web technology is... well, I guess your only hope is Webassembly.
* In this talk you will learn why people invent things Webassembly - even though it's kinda sad.

----

TODO: Write Agenda.


Workshop is divided in 5 parts:

- Intro
- I/O and syscalls
- CPU
- Memory
- Concurrency

----

What this workshop is
=====================

- An intro into Performance thinking
- An attempt at understanding the machine we program on
- Some lesser know tricks
- A workshop. You gonna have to work for it.

----

What this workshop is not
=========================

- An exhausting list of tricks
- A lecture on algorithm and data structures - pick a book.
- Something you just listen and it clicks
- Application specific performance tips (Networking, SQL, ...)

----

You need to experiment yourself
===============================

We will write our own little databases in this workshop.

* You can group up or do it on our own if you must.
* You can also use your favourite programming language.
* You can always ask me outside the workshop when writing it.

TODO: Move the explanation of LSM dbs to intro and re-order io and cpu?

----

What is performance optimization?
=================================

TODO: Wikipedia.

Optimizing different metrics that

----

When to apply it?
=================

* Probably more often than you do now.
* Whenever your performance requirements are not fulfilled.

Wait, there are requirements?

----

How to figure out performance criteria?
=======================================

Well, that's your job mostly. Your PM won't tell you most of the time.
But they will help you to get the requirements.

Ask those questions:

* On what kind of system the software will run on?
* How many users will there be in parallel?
* What kind of latency is the user willing to accept? (games, websites, ATMs)
* How much scaling is expected in the next time?
* Will my technology choice be a bottleneck? (Electron)
* Do edge cases need to perform well?
* Are the optimizations worth the risk/effort?
* ...

Do some basic calculations based on these and add X to your goals.

.. note::

   Do not ask: How fast could this be?
   (that's a fine question for personal learning though,
   but not when you get paid for delivering value to a company ;-))

   After this workshop you should be able to onvert the answers to those questions
   to measurable numbers.

   Edgecases are a good point: Sometimes performance is only bad in certain cases.
   Ask your PM if those are important for your business.
   If it's a open source library, probably fix those edge cases too.

----

When not to apply it?
=====================


| "Programmers waste enormous amounts of time thinking about, or worrying
| about, the speed of noncritical parts of their programs, and these attempts at
| efficiency actually have a strong negative impact when debugging and
| maintenance are considered. We should forget about small efficiencies, say
| about 97% of the time: premature optimization is the root of all evil. Yet we
| should not pass up our opportunities in that critical 3%."

-- Donald Knuth

.. note::

   If you don't have a problem you really should not do anything.
   It is difficult to define what a "problem" is.
   Electron apparently defined that it's not a problem if low-memory devices
   can't use their framework.

----

How do I know if it's premature?
================================

.. image:: images/premature_optimization_flowchart.png

Remember: It does not matter you fast you compute a wrong result.

.. note::

   The main point is: Take your time to do things the right away. Don't drop the pen
   when it worked for the first time and didn't feel slow, really take some to measure.

   However, don't just blindly optimize things before you measured or optimize the small
   things after measuring.

   Optimizations come at a price. It's usually more and harder code to maintain (and if not,
   why didn't you do it in the first place?) or they have some other disadavntages (an index
   in a database for example slows drown writes and needs space!). Is it worth the risk?

----


How do I measure?
=================

Via automated benchmarkings.

.. note::

    The how will be shown

----

How do I know how to optimize?
==============================

No short answer and no shortcuts to this.
It will be a long journey and this is workshop will be only a step on the journey.

Very many different languages, OS (Python, Go) and many different applications
(SQL - 90%: just add an index) that cannot all be covered.

But there are some common basics and more importantly a commone thinking behind all of it.
And that is: **You have to understand what your program is doing to optimize it.**

----

In a nutshell: Go from big to small
===================================

0. Do the obvious things right away. ("obvious" depends a lot on experience)
1. Check if your requirements are met. If you don't have concrete performance requirements, make some.
2. Benchmark to find the biggest bottlenecks regarding performance (we are incredible bad at guessing! Never skip this step)
3. Optimize biggest offender found and repeat from step 1.

Never mix up this order.

----

What is this program doing?
===========================

.. code-block:: python

    import sys
    print(sys.stdin.readline().strip())


.. note::

   Interpreted -> compiled to byte code.
   sys.stdin.readline are two dict lookups.
   memory allocations
   file I/O from stdin to stdout
   calling a c function (strip)
   unicode conversion!

----

Inside Python
=============

All functions eventuall call functions implemented in C:

.. code-block:: python

    static PyObject *
    strip(PyObject *self, PyObject *args)
    {
        char *s = NULL;
        if (!PyArg_ParseTuple(args, "s", &s)) {
            return NULL;
        }

        return PyUnicode_FromString(s);
    }
}



.. note::

   And that happens for every function call in Python. Very often.
   All those objects are allocated on the heap. Python is easy, but the price you pay for it
   is high. This might give you a first feeling on how much stuff happens in a simple program.

   Printing to stdout and drawing something on the screen is insanely complex too and beyond
   this workshop.

----

A word on interpreted languages
===============================

TODO: needed?

- Many things in this workshop do not apply to you 1:1.
- If you follow this workshop, a compiled language helps.
- TODO

Maybe some day you have to extend your language with a C module?

----

Theory: Complexity
==================

* Data structures and algorithms can be divided in performance classes.
* General types are space and time complexity.
* Often also divided in worst case, best case, average case

    O(1) -> constant
    O(n) -> linear
    O(log n) -> logarithmic
    O(n * log n) -> sorting
    O(n ** x) -> polynomial
    O(x ** n) -> exponential
    O(n!) -> fucktorial (oops, typo)

.. note::

    Data structures and algorithms:

    -> Some have better space / time complexity.
    -> Most have tradeoffs, only few are universally useful like arrays / hash tables
    -> Some are probalibisitic: i.e. they save you work or space at the expense of accuracy (bloom filters)
    -> Difference between O(log n) and O(1) is not important most of the time.
       (database developers might disagree here though)

----

Complexity examples
===================

* Time complexity of bubble sort?
* Time complexity of binary search (worst + best)?
* Space complexity of merge sort vs quick sort?
* Removing an element from an array vs from a linked list?
* Best case / Worst case time complexity of get and set of a hash table?
* Space complexity of a hash map?

.. note::

   TODO: worst case / best case example

   n**2
   log2 n
   n vs 1
   n vs 1
   1 and 1 (but much more expensive than an array index)
   n

   Makes you wonder why you don't use hash maps all the time?
   Indeed they are a wonderful invention, but:

   * get is still much more expensive than an array index.
   * collisions can happen, making things inefficient.
   * range queries and sorting are impossible.
   * self balancing trees have O(log n) for get/set but are stable.

----

Benchmarking
============

Tests that measure performance requirements.

* Heavily tied to hardware.
* Requires

What are possible performance metrics?

.. code-block::

   Collect possible performance metrics (unit in parans):

   * Execution time (time, cpu cycles)
   * Latency (time)
   * Throughput (IO, bytes/sec)
   * Memory (allocations, peak, total bytes)

----

Humans are bad at magnitudes
============================

https://colin-scott.github.io/personal_website/research/interactive_latency.html

In general:

* CPU < Memory < Files < Network.

Optimize in that order.

----

Profiling
=========

Profiling is like benchmarking, but just once.

.. note::

   Profiling is usually used for finding a bottleneck,
   but you benchmark a program as part of it.

   So most of the time the terms can be used interchangeably.

----


Benchmarking and Statistics
===========================

.. code-block:: bash

   $ hyperfine


.. note::

   * Run several times.
   * If the variance is not big, take the maximum.
   * If the variance is rather large, use min...max.

---

Benchmarking and CI/CD
======================

https://github.com/dandavison/chronologer

.. note::

   In an ideal world, performance requirements are tested just like
   normal functional requirements.

   Challenges:

   * Different machines that benchmarks run on.
   * Only comparison between releases makes sense.

   Makes sense only for big projects. Many projects have
   their own set of scripts to do this. I'm not aware of a standard solution.


----

IO for a simple key value store:

0. You could use a bigh in-memory hash table and sync that to disk
   periodically. This is what Redis does, but it sucks if you have more
   keys/values than memory. But very efficient.
   Also, not very fail-safe in case of powerloss.

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
