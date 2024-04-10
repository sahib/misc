build:
	marp .

publish: build
	rm -rf /tmp/slides
	mkdir -p /tmp/slides
	cp -r ./distplot/ /tmp/slides
	cp -r ./images/   /tmp/slides
	cp ./slides.html  /tmp/slides/index.html

	git checkout gh-pages
	rm -rf distplot images index.html
	cp -r /tmp/slides/* .
	git add --force .
	git commit --allow-empty -m "updated slides"
	git push origin gh-pages
	git checkout master
