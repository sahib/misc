all:
	go build -o deadlock main.go

debug:
	dlv attach $(pgrep deadlock) ./deadlock
