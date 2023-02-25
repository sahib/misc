setup:
	dd if=/dev/urandom of=./big-file bs=1M count=1024
	sync

drop_cache:
	sync; echo 3 | sudo tee /proc/sys/vm/drop_caches


time_it:
	time cat ./big-file > /dev/null
