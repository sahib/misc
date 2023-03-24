all: intro cpu memory io concurrent toc homework

homework:
	typst homework.typ

onepage:
	hovercraft onepage.rst slides/onepage

intro:
	hovercraft 1_intro.rst slides/1_intro

cpu:
	hovercraft 2_cpu.rst slides/2_cpu

memory:
	hovercraft 3_memory.rst slides/3_memory

io:
	hovercraft 4_io.rst slides/4_io

concurrent:
	hovercraft 5_concurrent.rst slides/5_concurrent

toc:
	hovercraft 0_toc.rst slides/toc

publish:
	rm -rf /tmp/slides
	cp slides /tmp/slides -r
	git checkout gh-pages
	rm slides -rf
	cp /tmp/slides . -r
	git add slides
	git commit --allow-empty -m "updated performance workshop"
	git push origin gh-pages
	git checkout master
