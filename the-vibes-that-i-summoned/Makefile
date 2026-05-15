slides.pdf:
	typst compile slides.typ
	polylux2pdfpc slides.typ

present: slides.pdf
	pdfpc -w both slides.pdf

slides-with-notes.pdf:
	typst compile --input notes=true slides.typ slides-with-notes.pdf

all: slides.pdf slides-with-notes.pdf
