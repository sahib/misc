:title: Compression
:data-transition-duration: 950
:css: hovercraft.css

----

Compression

----

Agenda
======

* How does compression work?
* Encoding vs Algorithm
* General vs Special Purpose
* Lossy vs Lossless
* Speed vs Ratio
* How widespread is that method?



Let's build an algorithm!
=========================

Compress ASCII English text:

- Give each valid english word a number.
- Instead of the word, we use the usually shorter number.
- If number is longer than the word or we can't find the word, then use the word verbatim (needs some structure to distinguish!)
- We can sort the most frequent words in the front, so the IDs for most frequent words get smaller.
  This would allow us to do something like in Unicode: More complicated
- Idea: We could also use word stemming to save something like "this was a verb and the stem is water" instead of "watering"

----

Encoding vs Algorithm
=====================

Encoding: gzip
Algorithm: DEFLATE


----

Packing
=======

Some formats like WOFF2 bring the data in a specific form before using a general purpose algorithm:

https://disorganizer.github.io/brig-thesis/brig/html/images/7/stride.png

They use packing to group blocks of potentially similar looking files together to increase the ratio.
This is also was git does. Why does this help? Because general purpose algorithms (usually) work with a
window where they try to recognize similar patterns. This window might be sliding, but if something happens
to repeat often in a distance that is higher than the window size then the compression algorithm cannot pick
it up.

Example: CSV: Instead of encoding row1col1 row1col2 row1col3 we can do row1col1 row2col1 row3col1

----

General Purpose:

* lz4, snappy, zip, gzip, ...

Special Purpose:

* PNG, MP3, H.265, delta compression ...

Lossy vs Lossless
=================

Lossy:

* mp3, jpeg, H.265

Lossless:

* wav, png, H.265


Lossy
=====

* Reduction of irrelevant noise
* Inaccuracies in human perception are used to leave out data that we will
  likely not notice anyways.

Examples:

* Bei 192 kbit/s von den meisten Höreren kein Unterschied feststellbar.
* Colors are not as significantly perceived as brightness difference.
  -> More bits of Brightness, less for color. This gets worse for older people.
* Videos get divided in Key-Frames and only the difference between each key frame is
  encoded -> High compression ratio

Disadvantage:

* Compression artifacts that won't go away.

Special case: pngquant
======================


https://pngquant.org

Adds a lossy compression step to PNG, with similar
compression rates as JPEG while still supporting transparency.

Uses posterization and dithering

https://gif.ski/ <- also works for gifs!

Lossless
========

Only valid choice if you don't know much about the data
or if all bits must be the same after decompression.

Disadvantage:

* By far not as high ratio as losless.

Special case: Pi
================

Pi can be "compressed" by remembering the formula and not the value.

Lossy algorithms use this by remembering the coefficients in a formula
that reconstructs a wave, image block or something else (Taylor Series, anyone?)

https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/Sintay_SVG.svg/1280px-Sintay_SVG.svg.png


Interesting lossy algorithms you might not have heard yet
=========================================================

* JPEG2000/JPEG XL:
* WebP: Very nice

Interesting losless algorithms you might not have heard yet
============================================================

* Brotli
* Zipfli

Speed vs Ratio
==============

Is encoding or decoding speed important?

* Game Assets: Fast decoding, encoding not important.
* Real-time data: Needs to be encoded fast & well enough. Decoding on more potent machine.

Ratio:

* Sometimes compressed ratio can be over the source file (zip of a zip)
* Comparing overall performance requires inclusion of ratio too.

How many people understand you?
===============================

Choosing an algorithm is not only about speed & ratio.
Depending on the format there are other hard requirements:

* Does the format allow embedding some metadata? geotags for images e.g.
* Are you in control of encoding and decoding side?
* Do popular programs like browser support the algorithm?
* Does it support transparency? HDR data? (for images)
* Can you seek in the archive?
* Does your hardware enable support?

Video encoding did it well: Container formats emerged, that, while confusing,
can be extended easily to include video / audio / subtitle streams with different
encodings and compression schemes. Image formats are not so great here.
There was RIFF, but it did not really proliferate.

Tips:
=====

* If you choose a compression algorithm, make it exchangeable.
* Use your domain knowledge with packing for better ratios.
* If you can, use lossless algorithms, lossy if you must.
* General Purpose lossless: lz4
* Lossy Audio: AAC (?!)
* Lossless Audio: FLAC
* Lossy Images: PNG Quant / WebP
* Lossless Images: PNG
* Lossy Video: No idea?
* If you use Go: https://github.com/klauspost/compress
* Using compression does not free you from using a compact file format (i.e. CSV is not the best choice)


General Purpose List:
=====================

* zstd
* Snappy / S2
* lz4
* lzma
* lzham
* DEFLATE (zip, gzip)
* bzip2


Under the hood:
===============


* Huffmann Encoding?
* Snappy as example for the window logic



How to choose?
==============
