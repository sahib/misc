# Performance workshop

This directory contains the sources for the performance workshop.
After publishing it is available here:

https://sahib.github.io/misc/performance/slides/0_toc/index.html

## Video Recording

The workshop was given end of 2023 and there is a recording available here:

https://vimeo.com/888379442

## Tools used

* ``hovercraft`` to build the slides from rST.
* ``d2`` to produce diagrams (see ``diagrams/``)
* ``rst2html`` and ``wkhtmltopdf`` for the PDF version.
* ``typst`` to render PDFs for the homework.
* ``make`` as ``make``

If you want live update, then just issue `make watch` and open the slides in
`epiphany` (it auto-reloads on change).

## Fonts used

* Roboto Slab for most typesetting
* Jetbrains Mono for most code
* OpenMoji for Emojis

## Usage

Just `make` and open the slides in your browser.
