all: compile

compile:
	gcc fadvise.c -o fadvise -Wall -Wextra -O2

big-file:
	dd if=/dev/urandom of=./big-file bs=1M count=1024

drop_cache:
	sync; echo 3 | sudo tee /proc/sys/vm/drop_caches

time_it: all big-file
	@sync; echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
	@./fadvise advice_normal read_seq ./big-file
	@sync; echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
	@./fadvise advice_seq read_seq ./big-file
	@sync; echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
	@./fadvise advice_random read_seq ./big-file
	@sync; echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
	@./fadvise advice_willneed read_seq ./big-file
	@sync; echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
	@./fadvise advice_dontneed read_seq ./big-file

	@sync; echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
	@./fadvise advice_normal read_random ./big-file
	@sync; echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
	@./fadvise advice_seq read_random ./big-file
	@sync; echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
	@./fadvise advice_random read_random ./big-file
	@sync; echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
	@./fadvise advice_willneed read_random ./big-file
	@sync; echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
	@./fadvise advice_dontneed read_random ./big-file

	@sync; echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
	@./fadvise advice_normal read_backwards ./big-file
	@sync; echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
	@./fadvise advice_seq read_backwards ./big-file
	@sync; echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
	@./fadvise advice_random read_backwards ./big-file
	@sync; echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
	@./fadvise advice_willneed read_backwards ./big-file
	@sync; echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
	@./fadvise advice_dontneed read_backwards ./big-file
