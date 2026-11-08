package main

import "core:fmt"
import vmem "core:mem/virtual"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

main :: proc() {
	part3()
}

Unit :: struct {
	id:     int,
	growth: int,
	limit:  int,
}

part1 :: proc() {
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)

	path := "./09/input"
	data, err := os.read_entire_file(path, arena_alloc)
	if err != nil {
		fmt.println("err reading file")
		return
	}

	units := make([dynamic]Unit, arena_alloc)
	for line in strings.split(string(data), "\n") {
		if line == "" {
			continue
		}
		splits := strings.split(line, ", ")
		idStr := strings.split(splits[0], "=")[1]
		growthStr := strings.split(splits[1], "=")[1]
		limitStr := strings.split(splits[2], "=")[1]
		id, _ := strconv.parse_int(idStr)
		growth, _ := strconv.parse_int(growthStr)
		limit, _ := strconv.parse_int(limitStr)
		unit := Unit{id, growth, limit}
		append(&units, unit)
		// fmt.printfln("id %d growth %d limit %d", id, growth, limit)
	}
	fmt.println(units)
	fmt.println()
	//array
	//we split array[i]== growth-1 else array[i]++
	//split -> array[i]/2 + append(array[i]/2)+ append(1)
	//loop through it and check at the end if count >= limit -> return count
	secondSum := 0
	outer: for unit in units {
		branches := make([dynamic]int, arena_alloc)
		append(&branches, 1)
		growth := unit.growth
		limit := unit.limit

		seconds := 2
		breaks := 0
		for {
			l := len(branches)
			for i := 0; i < l; i += 1 {
				cur := branches[i]
				if cur == growth - 1 {
					div := cur / 2
					branches[i] = div
					append(&branches, div, 1)
					breaks += 1
				} else {
					branches[i] = cur + 1
				}
			}

			sum := slice.reduce(branches[:], 0, proc(a, b: int) -> int {
				return a + b
			})
			// sum := sum(branches[:])
			if sum + breaks >= limit {
				fmt.println(branches)
				fmt.printfln(
					"id: %d seconds: %d sum: %d breaks: %d sum+breaks: %d limit: %d",
					unit.id,
					seconds,
					sum,
					breaks,
					sum + breaks,
					limit,
				)
				secondSum += seconds
				// break outer
				continue outer
			}
			// fmt.println(branches)
			// fmt.printfln(
			// 	"id: %d seconds: %d sum: %d breaks: %d sum+breaks: %d limit: %d",
			// 	unit.id,
			// 	count,
			// 	sum,
			// 	breaks,
			// 	sum + breaks,
			// 	limit,
			// )
			// fmt.println()
			seconds += 1
		}
	}

	fmt.println("sum seconds: ", secondSum)
}

part2 :: proc() {
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)

	path := "./09/input"
	data, err := os.read_entire_file(path, arena_alloc)
	if err != nil {
		fmt.println("err reading file")
		return
	}

	units := make([dynamic]Unit, arena_alloc)
	for line in strings.split(string(data), "\n") {
		if line == "" {
			continue
		}
		splits := strings.split(line, ", ")
		idStr := strings.split(splits[0], "=")[1]
		growthStr := strings.split(splits[1], "=")[1]
		limitStr := strings.split(splits[2], "=")[1]
		id, _ := strconv.parse_int(idStr)
		growth, _ := strconv.parse_int(growthStr)
		limit, _ := strconv.parse_int(limitStr)
		unit := Unit{id, growth, limit}
		append(&units, unit)
		// fmt.printfln("id %d growth %d limit %d", id, growth, limit)
	}
	fmt.println(units)
	fmt.println()
	//array
	//we split array[i]== growth-1 else array[i]++
	//split -> array[i]/2 + append(array[i]/2)+ append(1)
	//loop through it and check at the end if count >= limit -> return count
	secondSum := 0
	outer: for unit in units {
		branches := make([dynamic]int, arena_alloc)
		append(&branches, 1)
		growth := unit.growth
		limit := unit.limit

		seconds := 2
		breaks := 0
		for {
			l := len(branches)
			for i := 0; i < l; i += 1 {
				cur := branches[i]
				if cur == growth - 1 {
					div := cur / 2
					branches[i] = div
					append(&branches, div, 1)
					breaks += 1
				} else {
					branches[i] = cur + 1
				}
			}

			if breaks + 1 >= limit {
				// fmt.println(branches)
				fmt.printfln(
					"id: %d seconds: %d breaks: %d limit: %d",
					unit.id,
					seconds,
					breaks,
					limit,
				)
				secondSum += seconds
				// break outer
				continue outer
			}
			seconds += 1
		}
	}

	fmt.println("sum seconds: ", secondSum)
}

part3 :: proc() {
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)

	path := "./09/test"
	data, err := os.read_entire_file(path, arena_alloc)
	if err != nil {
		fmt.println("err reading file")
		return
	}

	units := make([dynamic]Unit, arena_alloc)
	for line in strings.split(string(data), "\n") {
		if line == "" {
			continue
		}
		splits := strings.split(line, ", ")
		idStr := strings.split(splits[0], "=")[1]
		growthStr := strings.split(splits[1], "=")[1]
		limitStr := strings.split(splits[2], "=")[1]
		id, _ := strconv.parse_int(idStr)
		growth, _ := strconv.parse_int(growthStr)
		limit, _ := strconv.parse_int(limitStr)
		unit := Unit{id, growth, limit}
		append(&units, unit)
		// fmt.printfln("id %d growth %d limit %d", id, growth, limit)
	}
	fmt.println(units)
	fmt.println()
	//array
	//we split array[i]== growth-1 else array[i]++
	//split -> array[i]/2 + append(array[i]/2)+ append(1)
	//loop through it and check at the end if count >= limit -> return count
	secondSum := 0
	outer: for unit in units {
		branches := make(map[int]int)
		branches[1] = 1
		growth := unit.growth
		limit := unit.limit

		seconds := 2
		breaks := 0
		for {
			newBranches := make(map[int]int)
			//todo codex what would be an idea so that I don't need to loop over and over again over the map and can faster add stuff to the map
			//I know this can be done easier
			for cur, values in branches {
				if cur == growth - 1 {
					div := cur / 2

					ones := newBranches[1]
					newBranches[1] = values + ones

					curDivs := newBranches[div]
					newBranches[div] = values * 2 + curDivs

					breaks += values
				} else {
					curs := newBranches[cur + 1]
					newBranches[cur + 1] = values + curs
				}
			}
			delete(branches)
			branches = newBranches

			if breaks + 1 >= limit {
				// fmt.println(branches)
				fmt.printfln(
					"id: %d seconds: %d breaks: %d limit: %d",
					unit.id,
					seconds,
					breaks + 1,
					limit,
				)
				secondSum += seconds
				// break outer
				continue outer
			}
			seconds += 1
		}
		delete(branches)
	}

	fmt.println("sum seconds: ", secondSum)
}
