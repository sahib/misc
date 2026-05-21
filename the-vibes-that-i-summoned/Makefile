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
watch: all
	typst watch --input notes=true slides.typ slides-with-notes.pdf

.PHONY: publish
publish: slides.pdf slides-with-notes.pdf
	rm /tmp/pubslides -rf
	mkdir -p /tmp/pubslides
	cp slides.* /tmp/pubslides
	git stash
	git checkout gh-pages
	cp /tmp/pubslides/* .
	git add .
	git commit -am 'updated slides'
	git checkout master
	git stash pop
	git push origin gh-pages


all: slides.pdf slides-with-notes.pdf
