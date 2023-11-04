all: compile

compile:
	gcc fadvise.c -o fadvise -Wall -Wextra -O2

2G:
	dd if=/dev/urandom of=./2G bs=1M count=512

drop_cache:
	sync; echo 3 | sudo tee /proc/sys/vm/drop_caches

time_seq: all
	@sudo hyperfine \
		--export-markdown bench_seq.md \
		--export-json bench_seq.json \
		--setup 'make 2G && make compile' \
		--prepare 'make drop_cache' './fadvise advice_normal   read_seq       ./2G'   \
		--prepare 'make drop_cache' './fadvise advice_seq      read_seq       ./2G'   \
		--prepare 'make drop_cache' './fadvise advice_random   read_seq       ./2G'   \
		--prepare 'make drop_cache' './fadvise advice_willneed read_seq       ./2G'   \
		--prepare 'make drop_cache' './fadvise advice_dontneed read_seq       ./2G'   \
		--cleanup 'rm -f 2G'

time_random: all
	@sudo hyperfine \
		--export-markdown bench_random.md \
		--export-json bench_random.json \
		--setup 'make 2G && make compile' \
		--prepare 'make drop_cache' './fadvise advice_normal   read_random    ./2G'   \
		--prepare 'make drop_cache' './fadvise advice_seq      read_random    ./2G'   \
		--prepare 'make drop_cache' './fadvise advice_random   read_random    ./2G'   \
		--prepare 'make drop_cache' './fadvise advice_willneed read_random    ./2G'   \
		--prepare 'make drop_cache' './fadvise advice_dontneed read_random    ./2G'   \
		--cleanup 'rm -f 2G'

time_backwards: all
	@sudo hyperfine \
		--export-markdown bench_backwards.md \
		--export-json bench_backwards.json \
		--setup 'make 2G && make compile' \
		--prepare 'make drop_cache' './fadvise advice_normal   read_backwards ./2G'   \
		--prepare 'make drop_cache' './fadvise advice_seq      read_backwards ./2G'   \
		--prepare 'make drop_cache' './fadvise advice_random   read_backwards ./2G'   \
		--prepare 'make drop_cache' './fadvise advice_willneed read_backwards ./2G'   \
		--prepare 'make drop_cache' './fadvise advice_dontneed read_backwards ./2G'   \
		--cleanup 'rm -f 2G'

time_directions: all
	@sudo hyperfine \
		--export-markdown bench_directions.md \
		--export-json bench_directions.json \
		--setup 'make 2G && make compile' \
		--prepare 'make drop_cache' './fadvise advice_normal   read_seq       ./2G'   \
		--prepare 'make drop_cache' './fadvise advice_normal   read_random    ./2G'   \
		--prepare 'make drop_cache' './fadvise advice_normal   read_backwards ./2G'   \
		--cleanup 'rm -f 2G'
