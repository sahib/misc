all:
	@go build -o counter counter.go
	@printf "%20s %15.0f\n" "mutex" "$$(./counter mutex)"
	@printf "%20s %15.0f\n" "atomic" "$$(./counter atomic)"
	@printf "%20s %15.0f\n" "strided" "$$(./counter strided)"
	@printf "%20s %15.0f\n" "strided-pad" "$$(./counter strided-pad)"
