build:
	go build main.go

trace:
	go tool trace ./trace.out

bench: build
	/usr/bin/time -f '%es %P' ./main 1   10 1>/dev/null
	/usr/bin/time -f '%es %P' ./main 10  10 1>/dev/null
	/usr/bin/time -f '%es %P' ./main 100 10 1>/dev/null

	/usr/bin/time -f '%es %P' ./main 10  100 1>/dev/null
	/usr/bin/time -f '%es %P' ./main 100 100 1>/dev/null
