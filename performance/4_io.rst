Latency and Throughput
======================

Metaphor: a water pipe.

Latency = time until the first drop of water arrives
Throughput = How many liters of water we can pipe through

Examples:

* SSDs: Low latency, high throughput.
* HDDs: Medium latency, high throughput.
* Network: Often high latency, any kind of throughput.
* USB Stick over carrier pigeon: High latency, high throughput.

----

Hardware: HDDs
==============

.. image:: images/hdd.jpg

* Rotational, stacked disks.
* Reading head needs to seek to the right position.
* Mechanical system, bad at low/high temperature or moving systems.
* Dying technology, but battled tested & still widely used.

.. note::

   Big advantage: You could debug issues with too many seeks by audio!

   Also: did you ever try to shake your old laptop with a hdd while reading?

----

Hardware: SDDs
==============

.. image:: images/ssd.jpg

* Flash technology
* No expensive seek necessary.
* Limited number of write cycles.
* Becoming cheaper and better every year.

.. note::

    Write software for SSDs. There were some crazy tricks like FIEMAP to make
    applications re-order their reads in the order of how they are placed on disk.
    (Huge speedup on HDD, small speedup on SSD)

----

Virtual File System
====================

.. image:: images/vfs.webp

.. note::

   Below device drivers: hardware controllers - beyond this talk.
   They can also re-order writes and are mostly concerned with durability,
   i.e. a SSD controller will try to distribute the blocks he used to make sure
   they have a similar amount of write cycles.

----

How do syscalls work?
=====================

Only method of userspace to talk to kernel.
How to call is interrupt specific.

.. code-block:: asm

    movl $4, %eax   ; use the `write` system call
    movl $1, %ebx   ; write to stdout
    movl "Hello World!\n", %ecx ; use string "Hello World"
    movl $12, %edx  ; write 12 characters
    syscall         ; make system call via special instruction
                    ; The return code is in the eax register.

.. note::

   The syscall instruction performs a context switch.

   This means the current state of the process (i.e. the state of all registers
   in the CPU) is saved away, so it can be restored later. Once done, the kernel
   sets the register to its needs, does whatever is required to serve the system call.
   When finished, the process state is restored and execution continues.

   Context switches also happen when you're not calling any syscalls.
   Simply when the scheduler decide this process is done with execution.

----

Typical syscalls
================

* IO: ``read``, ``write``, ``close``
* Files: ``stat``, ``chmod``, ``mkdir``
* Memory: ``sbrk``, ``mmap``
* Processes: ``fork``, ``kill``, ``wait``
* Network: ``listen``, ``connect``, ``epoll``
* Mysterious: ``ioctl``, ``chroot``, ``mount``

.. note::

   Luckily for us, glibc and Go provide us nice names and interfaces to make those system calls.
   They usually provide thin wrappers that also do some basic error checking. Watch out: ``fread``
   is doing buffering in userspace!

   Can anyone think of another syscall not in the list above? exit! chdir, mkdir, chmod, ...

----

Syscalls are expensive
======================

.. code-block:: bash

   $ dd if=/dev/urandom of=./big-file bs=1M count=1024
   $ dd if=big-file of=/dev/null bs=1b
   4,07281 s, 264 MB/s
   $ dd if=big-file of=/dev/null bs=32b
   0,255229 s, 4,2 GB/s
   $ dd if=big-file of=/dev/null bs=1024b
   0,136717 s, 7,9 GB/s
   $ dd if=big-file of=/dev/null bs=32M
   0,206027 s, 5,2 GB/s

Good buffer sizes: 1K - 32k

.. note::

    Many syscalls vs a few big ones.

    Try to reduce the number of syscalls,
    but too big buffers hurt too.

----

Making syscalls visible
=======================

.. code-block:: bash

    $ strace ls /tmp


.. note::

   Insanely useful tool to debug hanging tools
   or tools that crash without a proper error message.

   Usually the last syscall they do give a hint.

----

Terminology: inode?
===================

The unique id of a file.
Several paths can have the same Inode.

.. code-block:: bash

    $ echo hello-world > file
    $ stat --format '%i' file
    1883
    $ ln file hardlink
    $ stat --format '%i' hardlink
    1883

.. note::

    There's a theoretical maximum of inodes per filesystem.
    Most filesystems prefer bigger files, since every file
    lookup has to lookup the right one in a big set of inodes.

----

Page cache
==========

* All I/O access is cached using the page cache (dir + inode)
* Free pages are used to store recently accessed file contents.
* Performance impact can be huge.

----

Clearing the cache
==================

For I/O benchmarks always clear all caches:

.. code-block:: bash

    sync; echo 3 | sudo tee /proc/sys/vm/drop_caches

.. note::

    Example: code/io_cache

----

Caveat: Writes are buffered!
============================

Make sure all file data is written to the hardware:

.. code-block:: bash

   sync

.. code-block:: c

   fsync(fd)

.. note::

   That's why we have the sync command before the drop_cache command.

----

Alternative to ``fsync()``
==========================

.. code-block:: bash

    # Move is atomic!
    $ cp /src/bigfile /dst/bigfile.tmp
    $ mv /dst/bigfile.tmp /dst/bigfile

.. note::

   This only works obviously if you're not constantly updating the file,
   i.e. for files that are written just once.

----

Typical read I/O
================

.. code-block:: c

    char buf[1024];
    int fd = open("/some/path", O_CREAT|O_RDONLY|O_TRUNC);
    size_t bytes_read = 0;
    while((bytes_read = read(fd, buf, sizeof(buf))) > 0) {
        /* do something with buf[:bytes_read] */
    }
    close(fd);

----

Typical write I/O
=================

.. code-block:: c

    char buf[1024];
    size_t bytes_in_buf = 0;
    int fd = open("/some/path", O_CREAT|O_WRONLY|O_TRUNC);
    do {
        /* fill buf somehow with data you'd like to write,
         * set bytes_in_buf accordingly.
         */
    } while(write(fd, buf, bytes_in_buf) >= 0)
    fsync(fd);
    close(fd);


.. note::

   There is a bug here:

   write() returns the number of written bytes.
   It might be less than `bytes_in_buf` and this is not counted as an error.
   The write call might have simply been interrupted and we expect that it is
   called another time with the remaining data.

   Also: Does the application that the data is immediately for read()?
   Answer: nope. You have to use fsync()

   Also please note: There is some error handling missing here.

----

Fixed write version
===================

.. code-block:: c

    /* ... */
    char *buf_ptr = buf;
    while(bytes_in_buf > 0) {
       size_t written = write(fd, buf_ptr, bytes_in_buf);
       bytes_in_buf -= written;
       buf_ptr += written;
       if(errno != 0) {
           return;
       }
    }
    /* ... */

.. note::

    Many write utils actually handle this for you.
    But io.Writer() behaves the same! Depending on the underlying
    file type and system this might be rare but is a real thing.

----

What about ``fread()``?
=======================

A weird accident in history.

**Usecases:**

* You need to read byte by byte.
* You need to unread some bytes frequently.
* You need to read easily line by line.

Otherwise: Do not use.

.. note::

    Userspace buffered functions. No real advantage, but limiting and confusing API.
    Has some extra features like printf-style formatting.

    In Go the normal read/write is using the syscall directly,
    bufio is roughly equivalent to f{read,write} etc.
    fsync() is a sycasll, not part of that.

----

Detour: Filesystems
===================

Performance depends a little on filesystem:

* ext2/3/4: good, stable & fast choice.
* fat8/16/32: simple, but legacy, do not use.
* NTFS: slow and only for compatibility.
* XFS: good with big files.
* btrfs: feature-rich, can do CoW & snapshots.
* ZFS: highly scalable and very complex.

.. note::

    Syscalls all work the same, but some filesystems have
    better performance regarding writes/reads/syncs or
    are more targeted at large files or many files.

    Most differences are admin related (i.e. integrity, backups,
    snapshots etc.)

----

Detour: Fragmentation
=====================

The problem that file content is distributed over many blocks.

.. code-block::

    Windows sucks but this term stuck in our heads.

    ext4 does not require fragmentation.


----

Detour: FUSE
============

.. image:: images/fuse.png

----

A note on seeking
=================

* Rotational disks have only one reading head.
* They re-order read requests
* This can increase latency!
* SSDs use

----

I/O improving performance
=========================

* Avoid I/O.
* Use a sane buffer size.
* Use append only data for writing.
* Batch writes as they evict caches.
* Prefer few big files over many small files.
* Avoid directories with high amount of files (``git``)
* For modifying big files use mmap.
* Buy faster hardware.
* Use a different I/O scheduler.
* Use a different filesystem (``tmpfs``)
* Leverage the page cache and trust the OS
* Use zero-copy techniques: ``sendfile``, ``splice``
* Not crazy: Use DMA if possible (hardware dependent)
* Slightly crazy: fadvise() if you need prefetch
* Maybe crazy: use O_DIRECT
* Likely crazy: skip fsync()
* Definitely crazy: FIEMAP

----

I/O scheduler
=============

Re-orders read and write requests for performance.

* ``none``: Does no reordering.
* ``bfq``: Complex, designed for desktops.
* ``mq-deadline``, ``kyber``: Simpler, good allround schedulers.

.. note::

    In the age of SSDs we can use dumber schedulers.
    In the age of HDDs schedulers were vital.

----

``ionice``
=========


.. code-block:: c

   $ ionice -c 2 -n 0 <some-pid>

* Default level is 4. Lower is higher.

.. note::

    Well, you can probably guess what it does.

----

Reduce number of copies
=======================

* Do not copy buffers in your program too often
* You can use ``readv`` to splice existing buffers to one.
* Use hardlinks if possible
* Use CoW reflinks if possible.
* ``sendfile()`` to copy files to Network.
* ``copy_file_range()`` to copy between files.

----

Homework
========

* Write a file copy utility in your favourite language and benchmark
  it against ``cp`` (the bash command). ``cp`` is probably faster.
  Why? How can you find out?

Basic store with get/set using append-only log,
plus segments compression and offset-table in memory.
Pay attention to efficient I/O and avoiding syscalls.

Optional: Implement delete using tombstones.

Use a programming language of your choice.

- Try to measure the amount of data (total and gets/sets) that your KV can store in a minute.
- Is there anything you can optimize here?
