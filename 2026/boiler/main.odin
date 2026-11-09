package main

import "../utils"
import "core:fmt"
import vmem "core:mem/virtual"
import "core:os"
import "core:strings"

main :: proc() {
	part1()
}

part1 :: proc() {
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)

	path := "./boiler/test"
	data, err := os.read_entire_file(path, arena_alloc)
	if err != nil {
		fmt.println("err reading file")
		return
	}

	for line in strings.split(string(data), "\n") {
		if line == "" {
			continue
		}
		fmt.println(line)
	}

}
