build:
	marp --html .

watch:
	marp --watch --server --html .


publish: build
	rm -rf /tmp/slides
	mkdir -p /tmp/slides
	cp -r ./images/   /tmp/slides
	cp ./slides.html  /tmp/slides/index.html

	git checkout gh-pages
	rm -rf images index.html
	cp -r /tmp/slides/* .
	git add --force .
	git commit --allow-empty -m "updated go quiz slides"
	git push origin gh-pages
	git checkout master
