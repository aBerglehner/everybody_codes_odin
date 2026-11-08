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

Memo_Key :: struct {
	x:      int,
	t:      int,
	growth: int,
}

count_splits :: proc(x, t, growth: int, memo: ^map[Memo_Key]int) -> int {
	if t <= 0 {
		return 0
	}
	dt := growth - x
	if t < dt {
		return 0
	}
	key := Memo_Key{x, t, growth}
	if value, ok := memo^[key]; ok {
		return value
	}
	remaining := t - dt
	value :=
		1 +
		2 * count_splits(growth / 2, remaining, growth, memo) +
		count_splits(1, remaining, growth, memo)
	memo^[key] = value
	return value
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
	secondSum := 0
	for unit in units {
		memo := make(map[Memo_Key]int, arena_alloc)
		lo := 0
		hi := 1
		for count_splits(1, hi, unit.growth, &memo) + 1 < unit.limit {
			hi *= 2
		}
		for lo < hi {
			mid := (lo + hi) / 2
			if count_splits(1, mid, unit.growth, &memo) + 1 >= unit.limit {
				hi = mid
			} else {
				lo = mid + 1
			}
		}
		fmt.printfln("id: %d seconds: %d", unit.id, lo + 1)
		secondSum += lo + 1
	}

	fmt.println("sum seconds: ", secondSum)
}
