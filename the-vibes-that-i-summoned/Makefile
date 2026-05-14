slides.pdf:
	typst compile slides.typ
	polylux2pdfpc slides.typ

present: slides.pdf
	pdfpc -w both slides.pdf

all: slides.pdf
