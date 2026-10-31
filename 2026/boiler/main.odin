package main

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
	part1()
}

part1 :: proc() {
	path := "./boiler/test"
	data, err := os.read_entire_file(path, context.allocator)
	if err != nil {
		fmt.println("err reading file")
		return
	}

	for line in strings.split(string(data), "\n") {
		if line == " " {
			continue
		}
		fmt.println(line)
	}

}
