.PHONY: slides.pdf
slides.pdf:
	typst compile slides.typ
	polylux2pdfpc slides.typ

present: slides.pdf
	pdfpc -w both slides.pdf

.PHONY: slides-with-notes.pdf
slides-with-notes.pdf:
	typst compile --input notes=true slides.typ slides-with-notes.pdf

.PHONY: watch
watch:
	typst watch --input notes=true slides.typ slides-with-notes.pdf

all: slides.pdf slides-with-notes.pdf
