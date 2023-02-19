


First step: Accept defeat
=========================

.. class:: substep

    - How good you think are we in testing our software?
    - How the f\*\*k do we measure that?
    - :math:`Q_{pm} = \frac{loc(test\_code)}{loc(app\_code)}`
    - Backend: :math:`0.27`
    - Firmware: :math:`0.21` (feels bad man)
    - SQLite: :math:`640` (what the fuck.)
    - Are we particularly bad? Not really.
    - Is SQLite way better at this? Oh yes.
    - Bonus: InfluxDB: :math:`0.3`

.. note::

  If we approach the topic humble, chances are better we learn something.

  Coverage is also a widely known way to measure how tested code is.
  We come to that in a minute.

  https://www.sqlite.org/testing.html

  if you wonder why the firmware has not so much: ui, most other services are small-ish)

----

Headlines from the Internet
===========================

TODO: Search articles that suggest that improving software quality is
      just a list of things you have to check off.

https://www.softwaretestinghelp.com/improve-software-quality/
https://towardsdatascience.com/14-ways-to-improve-software-quality-other-than-testing-a62d14936575
https://dev.to/d_ir/achieving-100-code-coverage-will-make-you-a-better-developer-seriously-30fc

.. note::

    Software engineering is a creative craft, opposed to things like mechanic engineering.

    Good quality cannot be achieved by mindlessly ticking off things on a checklist.
    Many articles in the internet suggest otherwise and you should not always belive
    the newest dogmas. Different things make sense for different teams.

    There is no right way to write software, just ways that suck differently.
    Be a pragmatic engineer, don't believe in dogmas like TDD or Patterns.

----

Meet your doom: SQLite
======================

Money quotes:

* ``veryquick`` consists of 285k distinct tests.
* Full run prior to releases consists of several billion (!) test runs.

Different test types:

* Four independently developed test harnesses
* 100% branch test coverage in an as-deployed configuration
* Millions and millions of test cases
* Out-of-memory tests
* I/O error tests
* Crash and power loss tests
* Fuzz tests
* Boundary value tests
* Disabled optimization tests
* Regression tests
* Malformed database tests
* Extensive use of assert() and run-time checks
* Valgrind analysis
* Undefined behavior checks
* Checklists

----


How much quality do we need?
============================

.. note::

    How is quality measured?

    Herraiz2010 "Beyond Lines of Code: Do we need more complexity metrics?" -> Probably still Lines of code.
    https://www.oreilly.com/library/view/making-software/9780596808310/ch08.html

TODO:

* Bastelbude
* Most-deployed Database in the world.

More tests <-> Slower development
More money <-> more tests
Simpler software (SQLite is simple compared to Postgres) <-> Better ratio (we are complex compared to Ottobock)

Actual question is: How much quality can be buy cheap?

-----

The lifecycle of mistakes
=========================

1. Testing: Just don't commit bugs
2. Prevention: Defensive Programming
3. Debugging: Fuck, I committed bugs.
4. Profiling: Oh wow, now it's slow.

.. note::

    Table of contents

-----

1. Testing: Types
=================

* Unittests
* Integration tests
* End-to-End tests
* Smoke tests
* Benchmarks/Load testing
* Pen testing


TODO: Diagram with effort vs coverage

TODO: A good mix.

.. note::

    That's not a strict law, sometimes unit and integration test
    flow into each other.

    Also, the list is not complete.

-----

1. Testing: Rules
=================

* Should be automated (if possible at all -> Matlab, UI, hardware)
* Should be easy, fast and effortless to run (possible to divide into sets)
* Happy path is not enough, but the most important one.
* Unit tests should have no dependencies
* Don't test things that are not in your software (json.Marshal)
* Tests should be stateless and may run in parallel (``stretchr/testify`` sucks)

TODO: More?

1. Testing: Unit
================

Example with go test
Everyone saw a test already, so let's focus on how it's done in Go

t.FailNow()
t.Run()
t.Parallel()

stretchr/require

1. Testing: Terms
=================

Black/White/Grey box

Blackbox vs whitebox in Go -> different packages.

Mocks, fakes, dummies

1. Testing: Table driven tests
==============================

Parametrized tests in other languages / frameworks.
Table because in Go you implemented them by writing a table.

1. Testing: Types of Coverage
=============================

You see often badges like "100% test coverage" in the internet.
Sounds great, does it? -> Cargo Cult (Begriff erklären)

But what the heck does that even mean?

go test -cover -> statement coverage

----

1. Testing: Statement coverage
==============================

-> Many open source projects claim 100% coverage.
-> That's what they mean.
-> Please don't do this.

.. code-block:: bash

    func f(max int) int {
        result := 1
        for idx := 0; idx < max; idx++ {
            if result < 1000 {
                result *= idx
            }

            result += idx
        }

        return result
    }

----

1. Testing: Branch coverage
===========================

-> SQLite has fucking 100%

.. code-block:: bash

    TODO

----

1. Testing: Condition coverage
==============================

.. code-block:: bash

    TODO

----

1. Testing: Fuzzing
====================

.. code-block:: bash

    TODO: Use Go 1.18 fuzzing

----

2. Prevention
=============

Statistics: Average number of bugs per line.
Still a fact: With enough lines of code, there will be bugs, no matter
the experience level.

2. Prevention: Out of scope
===========================

* Software design choices to lower number of bugs (good design result in lower )
* Software processes that improve communication and therefore lower mistakes.
  Communication: Many bugs happen when two software systems talk to each other.
  But not the right language.

2. Prevention: The language
===========================

choose a language with strict type system:

* Ada
* Rust
* Go, Haskell
* Elm
* Typescript

Nopes:

* C
* Python
* PHP
* Bash (well, for bigger software)

2. Prevention: Use the tools, Luke!
===================================

static analyzers

2. Prevention: Complexity
=========================

special case: software complexity can be measured and acted up on (McCabe, cyclomatic complexity)

feature creep (case of log4j, Software complexity must be measured as the sum of all dependencies)

2. Prevention: Regressions
==========================

Bug fixes should be considered
(do we do this? often, but not always)

2. Prevention: Documentation
============================

Literate programming (jupyter kinda does this)
(bit too much for us)

Write go examples

Write good docstrings where necessary,
don't just write doc strings to make the linter shut up

Documentation should stay close
(that's also why I don't like Confluence for code docs.
Docs won't change when it's not close to the code)

2. Prevention: Pair Programming
===============================

2. Prevention: CI/CD Pipelines
==============================

CI/CD

2. Prevention: Code Reviews
===========================

Good commit messages
Assign only when really ready.

2. Prevention: Introspection
============================

- Design your software inspectable. Built command line tools that help you check what's going on

2. Prevention: Security
=======================

https://raw.githubusercontent.com/OWASP/Go-SCP/master/dist/go-webapp-scp.pdf

OWASP Juice Shop


2. Prevention: Learn from others
================================

Read other code bases and see how they handle errors
or what kind of CI/CD linters etc. they have.

Good code bases:

* Caddy (awesome documentation)
* Minio (impressive benchmarking)

3. Debugging
============

“If debugging is the process of removing software bugs, then programming must be the process of putting them in

- Nope: Software is complex and sometimes things break because of environment (disk full, not enough mem, other services have bugs and cascade)
- ...or just maybe you didn't test for the right thing: Most of the times the requirements were correctly implemented.
  Well, the requirements were maybe wrong.
- Also, software engineering is a team sport. Most bugs happen in communication.
- Use proper logs (for fuck's sake)
- Kill a Go process with SIGABRT to get its stack trace (pkill -ABRT "name")
- Debuggers are nice, but if you need one you should re-consider your life decisions.
  and easily live-debug the faulty behavior. Don't rely on individual knowledge, code it as script.
- Don't make complex software:

    Debugging is twice as hard as writing the code in the first place. Therefore, if you write the code as cleverly as possible, you are, by definition, not smart enough to debug it.

    (Brian Kernighan)

- git bisect
