package main

import "core:container/queue"
import "core:fmt"
import "core:mem"
import vmem "core:mem/virtual"
import "core:os"
import "core:strings"


main :: proc() {
	part3()
}

part1 :: proc() {
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)

	path := "./06/input"
	data, err := os.read_entire_file(path, arena_alloc)
	if err != nil {
		fmt.println("err reading file")
		return
	}

	adj := make(map[string][]string, arena_alloc)
	for line in strings.split(string(data), "\n") {
		if line == "" {
			continue
		}
		keyIndex := strings.index(line, ":")
		key, _ := strings.substring(line, 0, keyIndex)
		strs, _ := strings.substring(line, keyIndex + 1, len(line))

		adj[key] = strings.split(strs, ",")

		fmt.printfln("key: %s strs: %v", key, strs)
	}
	fmt.println("adj: ", adj)

	lookup := make(map[string]bool, arena_alloc)
	q: queue.Queue(string)
	queue.init(&q)
	defer queue.destroy(&q)

	queue.push_back(&q, "NULL")
	for queue.len(q) > 0 {
		next := queue.pop_back(&q)
		if next in lookup {
			continue
		}
		lookup[next] = true

		neighbours := adj[next]
		for n in neighbours {
			queue.push_back(&q, n)
		}
	}

	delete_key(&lookup, "NULL")
	fmt.println("lookup len: ", len(lookup))
}

part2 :: proc() {
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)

	path := "./06/input"
	data, err := os.read_entire_file(path, arena_alloc)
	if err != nil {
		fmt.println("err reading file")
		return
	}

	adj := make(map[string][]string, arena_alloc)
	for line in strings.split(string(data), "\n") {
		if line == "" {
			continue
		}
		keyIndex := strings.index(line, ":")
		key, _ := strings.substring(line, 0, keyIndex)
		strs, _ := strings.substring(line, keyIndex + 1, len(line))

		adj[key] = strings.split(strs, ",")

		fmt.printfln("key: %s strs: %v", key, strs)
	}
	fmt.println("adj: ", adj)

	lookup := make(map[string]bool, arena_alloc)
	q: queue.Queue(string)
	queue.init(&q)
	defer queue.destroy(&q)
	//check who used NULL -> in the neighbours
	//than take the key -> check who use the key as neighbour

	queue.push_back(&q, "NULL")
	for queue.len(q) > 0 {
		next := queue.pop_back(&q)
		if next in lookup {
			continue
		}
		lookup[next] = true

		for key in adj {
			for neighbour in adj[key] {
				if neighbour == next {
					queue.push_back(&q, key)
				}
			}
		}
	}

	delete_key(&lookup, "NULL")
	// fmt.println("lookup: ", lookup)
	fmt.println("lookup len: ", len(lookup))
}

part3 :: proc() {
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)

	path := "./06/input"
	data, err := os.read_entire_file(path, arena_alloc)
	if err != nil {
		fmt.println("err reading file")
		return
	}

	adj := make(map[string][]string, arena_alloc)
	for line in strings.split(string(data), "\n") {
		if line == "" {
			continue
		}
		keyIndex := strings.index(line, ":")
		key, _ := strings.substring(line, 0, keyIndex)
		strs, _ := strings.substring(line, keyIndex + 1, len(line))

		adj[key] = strings.split(strs, ",")

		// fmt.printfln("key: %s strs: %v", key, strs)
	}
	// fmt.println("adj: ", adj)


	lookupCount := make(map[string]int)
	versions := [3]string{"NULLv1", "NULLv2", "NULLv3"}
	for v in versions {
		lookup := lookupForVersion(adj, v, arena_alloc)
		for key in lookup {
			if !(key in lookupCount) {
				lookupCount[key] = 1
			} else {
				lookupCount[key] = lookupCount[key] + 1
			}
		}
	}
	res := 0
	for _, value in lookupCount {
		if value > 1 {
			res += 1
		}
	}
	fmt.println("res: ", res)
}

lookupForVersion :: proc(
	adj: map[string][]string,
	nullVersion: string,
	arena_alloc: mem.Allocator,
) -> map[string]bool {
	lookup := make(map[string]bool, arena_alloc)
	q: queue.Queue(string)
	queue.init(&q)
	defer queue.destroy(&q)

	queue.push_back(&q, nullVersion)
	for queue.len(q) > 0 {
		next := queue.pop_back(&q)
		if next in lookup {
			continue
		}
		lookup[next] = true

		for key in adj {
			for neighbour in adj[key] {
				if neighbour == next {
					queue.push_back(&q, key)
				}
			}
		}
	}

	delete_key(&lookup, nullVersion)
	// fmt.printfln("version: %s lookup: %v len: %d", nullVersion, lookup, len(lookup))
	return lookup
}
