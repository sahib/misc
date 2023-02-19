

General idea:

* Teaching you about the internals of program execution.
* Very neglected field - not much teached in studies, during day-to-day work "it worked (once)" is more important.
* Maybe you heard of Moore's law?
* Lemur's law: Software engineers get twice as incompentent every decade (only half ironic)
* In the 90s we still squeezed every byte of memory out of game consoles
* And last decade we invented things like Electron - I don't want you guys to invent something like Electron
* If you think Electron is a good idea, then please stop doing anything related to software engineering
* Maybe have a try with gardening, or do waterboarding in Guantanamo. Just do something less hurtful to mankind than Electron

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



Intro to Complexity Notation

When to optimize ("does not matter how fast you return wrong results")

https://go.dev/doc/diagnostics

Differences: Profiling - Tracing - Debugging - Statistics

What are hot loops?

Data structures:

-> Some have better space / time complexity.
-> Most have tradeoffs, only few are universally useful like arrays / hash tables
-> Some are probalibisitic: i.e. they save you work or space at the expense of accuracy (bloom filters)


Expectation management
======================

.. code-block::

    * This is more of a table of contents, than in-depth knowledge.
    * Therefore touching a lot of topics. Mostly Go, but also many general techniques.
    * TODO: Lückenfüller zwischen How-to-TDD und How-to-unittests.
    * You accept software is never perfect and never will be.
    * You accept you have to accept and manage mistakes.
    * You don't except this workshop to be complete in any way.
    * You don't expect that we implement all of the things mentioned.
    * You know not to belive everything the internet or Lemurs says.

.. note::

    My expectations:

    * You ask immediately when you did not understand something.
    * You will have some exercises in between.
    * You will not need to understand everything.
      In the worst case you get better in buzzword bingo.



Questions to ask:

* How fast does this thing need to be?
* Are optimizations worth the risk?

What people ask:

* How fast could this be?

or:

* It works, no need for optimization!

Rule of thumb:

Do the obvious things right away.
Check if your requirements are met, if not identity the biggest bottleneck(s) (don't optimize right away)
Then tackle this by going from the big to the small.

----

Not included:

- Network performance
- Database performance
- Any of the thousands of specific fields
- Long intro to data structures - pick a book.

That would be several semesters of material.
The material in this workshop is just one ;)

----


TOC:


* 4 Erkenntnüsse:
* Jeder der sich dafür interessiert schnelle Programme zu schreiben.
* Rare knowledge, less common knowledge.


Intro:

    * Warum Optimierung?
    * Contra: Donald Knuth: Premature Optimization is the root of all evil.
    * Pro: Moore's Law but software got bad faster then hardware got faster.
    * Berufsstolz: Man sollte schon schauen dass die Software möglichst wenig
      Resources nutzt. Frontendentwicklung heutzutage ist leider ein gutes Beispiel.
    * Electron etc. sind so fett dass es echt peinlich ist.
