-----

:class: chapter-class

CPU
===

--------------

How is code executed?
=====================

* Assembly vs Machine Code

    Assembly: 1:1 human readable interpretation of machine code.
    Machine code: machine readable instructions (each instruction has an id)
    Assembler: Program that converts assembly to machine code.

.. note::

    * This slides could be also a talk about "Why interpreted languages suck"

        Most optimizations will not work with python.
        As a language it's really disconnected from the HW - every single statement will cause 100s or 1000s of assembly instructions.
        Also there are no almost no guarantees how big e.g. arrays or other data structures will be and how they are layout in memory.
        You have to rely on your interpreter (and I count Java's JIT as one!) to be fast on modern hardware - most are not and that's why
        there's so much C libraries in python, making the whole packaging system a bloody mess.

--------------

Other terminology
=================

* Instruction Sets (RISC/CISC, x86, arm)
* Microarchitecture (Implementation of a certain IS - Coffee Lake and so on)
* Instruction Set Extensions / SIMD (AES, SSE etc.) (not usable in Go by now, except for automatism)

--------------

How is machine code stored? ELF!
================================

ELF (Executable and linkable format)

.. code-block:: bash

    $ readelf --sections /usr/bin/ls
    [...]
    [12] .text             PROGBITS         0000000000008020  00008020
    [...]
    [22] .data             PROGBITS         0000000000059000  00058000
    $ objdump --disassemble /usr/bin/ls

.. note::

   Beside storing the actual instructions ELF solves:

   * Storing debugging info
   * Making it possible to link with existing other libraries.
   * Includes a text (code) and data section (pre-initialized variables)
   * Different OS use different formats, but ELF is probably the most relevant for you
     and also the most widely known. Windows has a different one.

--------------

Go Assembler #1
===============

TODO: enable line numbers

.. code-block:: go

    package main

    //go:noinline
    func add(a, b int) int {
        return a + b
    }

    func main() {
        add(2, 3)
    }


-----

Go Assembler #2
===============

Go assembly = assembler for a fantasy CPU

.. code-block:: bash

  main.add STEXT nosplit size=4 args=0x10 locals=0x0 funcid=0x0 align=0x0
  	(test.go:4)	TEXT	main.add(SB), NOSPLIT|ABIInternal, $0-16
  	(test.go:4)	FUNCDATA	$0, gclocals·g2BeySu+wFnoycgXfElmcg==(SB)
  	(test.go:4)	FUNCDATA	$1, gclocals·g2BeySu+wFnoycgXfElmcg==(SB)
  	(test.go:4)	FUNCDATA	$5, main.add.arginfo1(SB)
  	(test.go:4)	FUNCDATA	$6, main.add.argliveinfo(SB)
  	(test.go:4)	PCDATA	$3, $1
  	(test.go:5)	ADDQ	BX, AX
  	(test.go:5)	RET
  (...)

.. note::

    Important: Explain registers!

    Can we just say: To make things faster you have to reduce the number of instructions?

    Sadly no. Modern CPUs are MUCH complexer than machines that sequentially execute instructions.
    They take all kind of shortcuts to execute things faster - most of the time.
    See also: Megaherz myth (-> higher clock = more cycles per time)

    Effects that may play a role

    * Not every instruction takes the same amount of cycles (MOV 1 cycle,
    * Pipelining
    * Superscalar Execution
    * Branch prediction / Cache prefetching
    * Out-of-order execution
    * Cache misses (fetching from main memory mean

    List of typical cycles per instructions ("latency"): https://www.agner.org/optimize/instruction_tables.pdf

--------------

Inlining functions
==================

Inlining functions can speed up things at the cost of increased ELF size.

Advantage: Parameters do not need to get copied, but CPU can re-use whatever
is in the registers alreadys. Also return values do not need to be copied.

Only done for small functions and only in hot paths.

----

Pipelining
==========

https://de.wikipedia.org/wiki/Pipeline_(Prozessor)

LOAD: Load the instruction from memory, increment instruction counter.
DECODE: Data for the command is loaded.
EXEC: Instruction is executed.
WRITEBACK: Result is written back to a register.

* Every instruction needs to do this
* Modern CPUs can work on many instructions at the same time
* They can be also re-ordered by the CPU!
* This can lead to issues when an instruction depends on results of another instructions! (branches!)
* It can even happen that we do unncessary work! See SPECTRE and MELTDOWN security issues!

----

Branch prediction
=================

... you can give hints to your CPU!

.. code-block:: c

    if(likely(a > 1)) {
        // ...
    }

    if(unlikely(err > 0)) {
        // ...
    }


No likely() in Go, compiler tries to insert those hints automayically.
Not much of an important optimization nowadays though as CPUs get a lot better:

https://de.wikipedia.org/wiki/Sprungvorhersage

(but can be relevant for very hot paths on cheap ARM cpus)

----

Branch prediction in real life
==============================

.. code-block:: go

    for(int i = 0; i < N; i++) {
        if (unsorted[i] < X) {
            sum += unsorted[i];
        }
    }

    for(int i = 0; i < N; i++) {
        if (sorted[i] < X) {
            sum += sorted[i];
        }
    }

.. note::

   Effect is unnotice-able if optimizations are enabled.
   Why? Compilers can make the inner branch a branchless statement.


----


Go 1.20: Profile Guided Optimization
====================================

Idea:

* Let program run in analysis mode.
* Capture data about what branches were hit how often.
* Use this data on the next compile to decide which branch is likely!

.. image:: images/pgo.png

.. note::

   Also decides on where to inline functions.

   https://tip.golang.org/doc/pgo

   Old news for languages like C.

----

Branchless programming
======================

... helps to reduce pipelining issues.

* Branchless: https://dev.to/jobinrjohnson/branchless-programming-does-it-really-matter-20j4

.. note::

   Probably not relevant in most cases, but can be a life saver in really hot loops.

----

Loop unrolling
==============

* A for loop is just a repeated branch condition.
* Compilers unroll simple loops.
* If they don't hand unrolling can be useful (very seldom!)

TODO: Example

----


Reduce number of instructions
=============================

memcpy example

TODO: Instrinsic

----

I want to MOV, MOV it
=====================

.. code-block::

  MOV <dst> <src>

.. code-block::

  MOV <reg> <reg>
  MOV <mem> <reg>
  MOV <reg> <mem>

-> Access to main memory is 125ns, L1 cache is ~1ns

Fun fact: MOV alone is Turing complete: https://github.com/xoreaxeaxeax/movfuscator

----

Types of memory
===============

Static memory (SRAM) vs Dynamic memory (DRAM)

SRAM:

* Much much faster
* Expensive as hell

DRAM:

* Has to be constantly refreshed.
* Needs complex handling of memory controllers
* Very cheap

----

The von Neumann Bottleneck
==========================

von Neumann Architektur:

* Computer Architecture where there is common memory accessible by all cores
* Memory contains Data as well as code instructions
* All data/code goes over a common bus
* Pretty much all computer nowadays are build this way

Bottleneck: Memory acess is much slower than CPUs can process the data.

----

L1, L2, L3
==========

Just add caches!

.. image:: images/whatcouldgowrong.jpeg

TODO: Add picture of cache architecture.

----

Cache lines
===========

typicall 64 byte
Read an written in one go!

----

Caches misses
=============

Unsure if you have cache misses? Use the `perf stat -p <PID>` command!

https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/monitoring_and_managing_system_status_and_performance/getting-started-with-perf_monitoring-and-managing-system-status-and-performance
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/monitoring_and_managing_system_status_and_performance/overview-of-performance-monitoring-options_monitoring-and-managing-system-status-and-performance

counter example 1-3

----

Detour: `perf` command
======================

System wide profiling

.. code-block:: bash

   perf stat -a <command>   # Like `time` but much better.
   perf stat -a -p <PID>    # Attach to existin process.
   perf mem                 # Detailed report about memory access / misses
   perf c2c                 # Can find false sharing (see next chapter)


----

Detour: Flame graphs
====================

TODO:

Attach to running program with perf record
Render flamegraph from output

Perfect to see what time is spend in in what symbol.
Available for:

* CPU
* Memory Allocations (although I like pprof more here)
* Off-CPU (i.e. I/O)

perf works (almost) always though and can be used to profile complete systems,
for specific programming languages better options might be available though.

----

Cache coherency
===============

In multithreaded programs, a cache gets evicted

----

False sharing
=============

Counter4 example.

Multiple threads use the same memory

Can be fixed by introducing padding!

* False sharing / True sharing (i.e. when to pad your data structures
  https://alic.dev/blog/false-sharing.html )

----

True sharing
============

This is when the idea of introducing caches between CPU and memory works out.
Good news: Can be controlled by:

* Limiting struct sizes to 64 byt
* Grouping often accessed data together.
  (arrays of data, not array of structs of data)
*

-> employee example

----

Data oriented programming
=========================

The science of designing programs in a CPU friendly way.

.. note::

   DOP is often mentioned as contrast to OOP, but both concepts can complement each other.

   Object oriented program is designing the program in a way that is friendly to humans.

   It does by encapsulating data and methods together. By coincidence, this is not exactly
   helpful to the machine your program runs on. Why?

   - global state (i.e. impure functions) make branch/cache predictions way harder.
   - hurts cache locality.

-----

Matrix Traversal
================

* Why is column traversal so much slower?


Good picture source: https://medium.com/mirum-budapest/introduction-to-data-oriented-programming-85b51b99572d

-----

Employees
=========

* Why is the variant with two arrays faster?
* What happens if we make the name array longer/shorter?

Array-of-Structures vs Structures-of-Arrays

https://www.dataorienteddesign.com/dodmain/

-----

``memcpy``
==========

* Why is the single-byte memcpy so much slower?
* What evil trick is the system memcpy doing?
* Can we do even faster?

.. note::

    -> Problem: von-Neumann-Bottleneck.
    -> CPU can work on data faster than typical RAM can deliver it.
    -> Workaround: Caches in the CPU, Prefetching.
    -> Actual solution: Data oriented design.
    -> Sequential access, tight packing of data, SIMD (and if you're crazy: DMA)
    -> Still best way to speed up copies: don't copy.

.. note::

    Object oriented design tends to fuck this up and many Games (at their core)
    do not use OOP. You can use both at the same time though!

----

Process scheduler
=================

We're not alone on a system. Every process get assigned a share of time that it may execute.

* After execution: Store state in RAM.
* Before execution: Load state from RAM.

.. image:: images/process_states.jpg

.. image:: images/process_states.webp

-> Expensive. Switching too often is expensive.

.. note::

    * scheduler types (O(n), O(1), CFS, BFS)
    * scheduler is determined at compile time.
    * there are some knobs to tune the scheduler, but not that interesting.
    * Show process states with `ps a`.

----

Process niceness
================

Niceness is the "weight" for a certain process during scheduling:

* Ranges from -20 to +19.
* -20 gives the process more time to execute.
* 0 is the default.
* +19 gives the process way less to execute.

Can be set via `nice` (new commands), `renice` (running programs)
Exact behaviour depends on scheduler (scheduling frequency vs time slice size)

----

Fun fact: Supercompilers
========================

TODO: Relevant?

* Compilers do not usually produce the best code and rely heavily on pattern matching, heuristics
  and just being smart. They can miss room for optimizations although this is rather rare in practice.
  (except Go, which is just a developing compiler)
* Super compilers brute force compilation (sometimes with benchmarks) until they found the best performing
  piece of code.
* Not used in practice, since freaking slow but helpful for developing new compiler optimizations.

.. note::

   STOKE: https://github.com/StanfordPL/stoke

-----

Rough Rules to take away
========================

0. Only use so much memory as you really need.
1. Writes modify the cache. Directly use your data or declare it later.
2. Keep your structs small.
3. Avoid nesting of data, if possible.
4. For small structures (<64 byte) prefer copying over pointers.
4. Avoid jumpin around in your memory a lot.

TODO: Revisit those rules.

----

Homework
========

TODO: Irgendwann hier aufgeben. Vielleicht perf? Oder irgendein Programm benchmarken?
