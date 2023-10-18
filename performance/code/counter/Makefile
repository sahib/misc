perf_fields =  cache-misses,context-switches,cpu-migrations,cycles,instructions,branch-misses
all:
	@go build -o counter counter.go
	@rm -f counts
	@perf stat -e $(perf_fields) ./counter mutex >> counts
	@perf stat -e $(perf_fields) ./counter atomic >> counts
	@perf stat -e $(perf_fields) ./counter strided >> counts
	@perf stat -e $(perf_fields) ./counter strided-pad >> counts
