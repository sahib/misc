all: build
build:
	go build -o katta main.go

count-lines-of-code:
	cloc $(find -type f -iname '*.go' ! -iname '*.capnp.go' ! -iname '*_test.go')
