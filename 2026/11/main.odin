package main

import "../utils"
import "core:container/queue"
import "core:fmt"
import vmem "core:mem/virtual"
import "core:os"
import "core:strconv"
import "core:strings"

main :: proc() {
	part1()
}

part1 :: proc() {
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)
	context.allocator = arena_alloc
	defer vmem.arena_destroy(&arena)

	path := "./11/test"
	data, err := os.read_entire_file(path, arena_alloc)
	if err != nil {
		fmt.println("err reading file")
		return
	}

	portals := 0
	connections := make([dynamic]int, arena_alloc)
	firstStep := true
	for line, i in strings.split(string(data), "\n") {
		if line == "" {
			firstStep = false
			continue
		}
		if firstStep {
			strs := strings.split(line, ": ")
			n, _ := strconv.parse_int(strs[1])
			portals = n
		} else {
			for s in strings.split(line, " ") {
				n, _ := strconv.parse_int(s)
				append(&connections, n)
			}
		}
		// fmt.println(line)
	}
	fmt.printfln("portals: %d connections: %v", portals, connections)
	// build a dependeny list just out of portals
	// we start at 1 <= protals -> add always the prev and next
	// ->prev for 1 == portals and next for protals is 1
	adj := make(map[int][dynamic]int, arena_alloc)
	adj[1] = make([dynamic]int, 0, 3)
	append(&adj[1], 2, portals)

	adj[portals] = make([dynamic]int, 0, 3)
	append(&adj[portals], portals - 1, 1)

	for i := 2; i < portals; i += 1 {
		prev := i - 1
		cur := i
		next := i + 1
		adj[cur] = make([dynamic]int, 0, 3)
		append(&adj[cur], prev, next)
	}
	fmt.println(adj)


	//key=portal value=steps
	minStepsByPortal := make(map[int]int)

	q: queue.Queue(Node)
	queue.init(&q)
	defer queue.destroy(&q)

	queue.enqueue(&q, Node{portal = 1, steps = 0})
	for queue.len(q) > 0 {
		cur := queue.dequeue(&q)
		protal := cur.portal
		steps := cur.steps
		if cur.portal in minStepsByPortal {
			//check
			prevSteps := minStepsByPortal[protal]
			//todo
		} else {
			minStepsByPortal[protal] = steps
		}

		for neighbour in adj[protal] {
			n := Node {
				portal = neighbour,
				steps  = steps + 1,
			}
			queue.enqueue(&q, n)
		}

	}
}

Node :: struct {
	portal: int,
	steps:  int,
}
