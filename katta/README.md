# Katta - An educational key-value store

This is a small key-value store focused on small memory footprint (in the sense
that memory does not increase linear with the amount of data). The tradeoff between
CPU usage and memory usage can be configured with some knobs.

## Overview

- Implements ``Get()``, ``Set()`` and ``Del()``.
- Uses a sparse index to be able to handle more keys than there is RAM.
- Very small code base with less than 1000 lines of code.
- Not optimized at all, making it good for showing various optimizing techniques.
- Only basic test-suite, which would be also great for learning in that area.

## Structure

See [my performance workshop](https://sahib.github.io/misc/performance/slides/1_intro/index.html#/step-33) for an intro on how LSM based key-value stores work.

* ``wal/``: Contains a very bare-bone implementation of a Write-Ahead-Log (WAL) and it's binary
  representation on disk. Cap'n'Proto is used for marshalling and unmarshalling. Since this is
  a very generic log of key-value pairs it is also used as binary representation for segments to keep the code small.
* ``index/``: Implements the index based on a B-tree. Always keeps the first and last
   key, all other keys can get deleted to make the index sparse. Also knows how to marshal
   and unmarshal itself.
* ``segment``: Glue code to load a list of segments with their indexes from disk and keep track of them.
   Mainly filesystem interaction and some convenience methods.
* ``db/``: Implements the actual logic to retrieve and set individual keys.

## Optimizations

Check the codebase for ``XXX`` comments and check the [homework.pdf](https://github.com/sahib/misc/blob/master/performance/homework.pdf) for more ideas.
