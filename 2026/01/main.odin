package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

main :: proc() {
	part3()
}

// check numbers to next square 2x2,3x3 and add the fill to res
part1 :: proc() {
	path := "./01/input"
	data, err := os.read_entire_file(path, context.allocator)
	if err != nil {
		fmt.println("err reading file")
		return
	}


	res := 0
	for line in strings.split(string(data), ",") {
		n, _ := strconv.parse_int(line)
		res += numsToNextSquare(n)
	}
	fmt.printfln("res: %d", res)
}

numsToNextSquare :: proc(num: int) -> int {
	for i := 1; i < 1_000_000; i += 1 {
		square := i * i
		if square >= num {
			return square - num
		}
	}

	return 0
}

//min is 3x3 in the middle at least on empty cell
part2 :: proc() {
	path := "./01/input"
	data, err := os.read_entire_file(path, context.allocator)
	if err != nil {
		fmt.println("err reading file")
		return
	}


	res := 0
	for line in strings.split(string(data), ",") {
		n, _ := strconv.parse_int(line)
		res += numsToNextSquare2(n)
	}
	fmt.printfln("res: %d", res)
}

numsToNextSquare2 :: proc(num: int) -> int {
	for i := 3; i < 1_000_000; i += 1 {
		square := i + i + i + i - 4
		if square >= num {
			return square - num
		}
	}

	return 0
}

part3 :: proc() {
	path := "./01/input"
	data, err := os.read_entire_file(path, context.allocator)
	if err != nil {
		fmt.println("err reading file")
		return
	}


	res := 0
	for line in strings.split(string(data), ",") {
		n, _ := strconv.parse_int(line)
		diff := numsToNextSquare3(n)
		// fmt.printfln("diff: %d", diff)
		res += diff
	}
	fmt.printfln("res: %d", res)
}

numsToNextSquare3 :: proc(num: int) -> int {
	for i := 3; i < 1_000_000; i += 1 {
		if i % 2 == 0 {
			continue
		}
		square := i * i - 1
		if square >= num {
			// fmt.printfln("i: %d squares: %d", i, square)
			return square - num
		}
	}

	return 0
}
