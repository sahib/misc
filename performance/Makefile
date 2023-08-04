default: 0_toc 1_intro 2_cpu 3_memory 4_io 5_concurrent homework.pdf
all: default onepage onepage.pdf

# Shortcuts:
onepage:      slides/onepage/index.html
0_toc:        slides/0_toc/index.html
1_intro:      slides/1_intro/index.html
2_cpu:        slides/2_cpu/index.html
3_memory:     slides/3_memory/index.html
4_io:         slides/4_io/index.html
5_concurrent: slides/5_concurrent/index.html

.PHONY: onepage.pdf
onepage.pdf: onepage.rst
	rst2html --quiet onepage.rst > onepage.html
	@rm -f onepage.pdf
	wkhtmltopdf --quiet --enable-local-file-access onepage.html onepage.pdf
	@rm -f onepage.html

%.pdf: %.typ
	typst $^

.PRECIOUS: %.svg  # save svg file from auto deletion
%.svg: %.d2
	d2 --center --sketch --theme 301 $^

diagram_outputs := $(shell grep -ho 'diagrams/.*' *.rst)
slides/%/index.html: $(diagram_outputs) %.rst hovercraft.css hovercraft.js
	hovercraft --slide-numbers $(filter %.rst,$^) slides/$* --js hovercraft.js
	cp highlight-trac.css slides/$*/css/highlight.css

watch:
	# okay, that's actually funny.
	sh -c 'while true; do make --silent; sleep 0.1; done'

publish: default
	rm -rf /tmp/slides
	cp slides /tmp/slides -r
	git checkout gh-pages
	rm slides -rf
	cp /tmp/slides . -r
	git add --force slides
	git commit --allow-empty -m "updated performance workshop"
	git push origin gh-pages
	git checkout master
