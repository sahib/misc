all: build deploy

build:
	GOOS=linux GOARCH=arm GOARM=7 go build .

deploy:
	scp morse pi@192.168.23.66:/tmp
	ssh pi@192.168.23.66 "sh -c 'sudo systemctl stop morse'"
	ssh pi@192.168.23.66 "sh -c 'sudo cp /tmp/morse /usr/bin/morse'"
	ssh pi@192.168.23.66 "sh -c 'sudo systemctl start morse'"
