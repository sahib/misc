package main

func SumNoTailcall(ls []int) int {
	if len(ls) == 0 {
		return 0
	}

	return ls[0] + SumNoTailcall(ls[1:])
}

func SumTailcall(ls []int) int {
	return doSumTailcall(0, ls)
}

func doSumTailcall(acc int, ls []int) int {
	if len(ls) == 0 {
		return 0
	}

	return doSumTailcall(ls[0], ls[1:])
}

func SumIterative(ls []int) int {
	acc := 0
	for idx := 0; idx < len(ls); idx++ {
		acc += ls[idx]
	}

	return acc
}
