package main

import "../utils"
import "core:container/queue"
import "core:crypto/_chacha20/ref"
import "core:fmt"
import "core:mem"
import vmem "core:mem/virtual"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

main :: proc() {
	part3()
}

Pair :: struct {
	a: int,
	b: int,
}

part1 :: proc() {
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)
	context.allocator = arena_alloc
	defer vmem.arena_destroy(&arena)

	path := "./11/input"
	data, err := os.read_entire_file(path, arena_alloc)
	if err != nil {
		fmt.println("err reading file")
		return
	}

	portals := 0
	connections := make([dynamic]Pair, arena_alloc)
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
			strs := strings.split(line, " ")
			a, _ := strconv.parse_int(strs[0])
			b, _ := strconv.parse_int(strs[1])
			append(&connections, Pair{a, b})
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
	fmt.println("adj before: ", adj)

	sum := 0
	for i in 1 ..= portals {
		v := getTeleportationSum(adj, i)
		sum += v
	}
	fmt.printfln("sum: %d", sum)

	//now we add connections
	for pair in connections {
		//we add a -> b and b -> a
		a := pair.a
		b := pair.b
		append(&adj[a], b)
		append(&adj[b], a)
	}
	fmt.println("adj after: ", adj)

	sum2 := 0
	for i in 1 ..= portals {
		v := getTeleportationSum(adj, i)
		sum2 += v
	}
	fmt.printfln("sum2: %d", sum2)

	res := sum - sum2
	fmt.printfln("res: %d", res)


}

Node :: struct {
	portal: int,
	steps:  int,
}

getTeleportationSum :: proc(adj: map[int][dynamic]int, start: int) -> int {

	//key=portal value=steps
	minStepsByPortal := make(map[int]int)
	defer delete(minStepsByPortal)

	q: queue.Queue(Node)
	queue.init(&q)
	defer queue.destroy(&q)

	queue.enqueue(&q, Node{portal = start, steps = 0})
	for queue.len(q) > 0 {
		cur := queue.dequeue(&q)
		protal := cur.portal
		steps := cur.steps

		if cur.portal in minStepsByPortal {
			prevSteps := minStepsByPortal[protal]
			if prevSteps < steps {
				continue
			} else {
				minStepsByPortal[protal] = steps
			}

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
	delete_key(&minStepsByPortal, start)
	sum := 0
	for _, value in minStepsByPortal {
		sum += value
	}
	fmt.printfln("sum: %d res: %v \n", sum, minStepsByPortal)
	return sum
}

part2 :: proc() {
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)
	context.allocator = arena_alloc
	defer vmem.arena_destroy(&arena)

	path := "./11/input"
	data, err := os.read_entire_file(path, arena_alloc)
	if err != nil {
		fmt.println("err reading file")
		return
	}

	portals := 0
	connections := make([dynamic]Pair, arena_alloc)
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
			strs := strings.split(line, " ")
			a, _ := strconv.parse_int(strs[0])
			b, _ := strconv.parse_int(strs[1])
			append(&connections, Pair{a, b})
		}
		// fmt.println(line)
	}
	fmt.printfln("portals: %d connections: %v", portals, connections)
	//3 nearest protals
	adj := make(map[int][dynamic]int, arena_alloc)
	// adj[1] = make([dynamic]int, 0, 3)
	// append(&adj[1], 2, portals)
	//
	// adj[portals] = make([dynamic]int, 0, 3)
	// append(&adj[portals], portals - 1, 1)

	for i := 1; i <= portals; i += 1 {
		prev1 := calcIndex(i - 1, portals)
		prev2 := calcIndex(i - 2, portals)
		prev3 := calcIndex(i - 3, portals)
		cur := i
		next1 := calcIndex(i + 1, portals)
		next2 := calcIndex(i + 2, portals)
		next3 := calcIndex(i + 3, portals)
		adj[cur] = make([dynamic]int, arena_alloc)
		s := []int{prev3, prev2, prev1, next3, next2, next1}
		for i := len(s) - 1; i >= 0; i -= 1 {
			if s[i] != 0 {
				append(&adj[cur], s[i])
			}
		}
	}
	delete_key(&adj, 0)
	fmt.println("adj before: ", adj)

	sum := 0
	for i in 1 ..= portals {
		v := getTeleportationSum2(adj, i)
		sum += v
	}
	fmt.printfln("sum: %d", sum)

	//now we add connections
	for pair in connections {
		//we add a -> b and b -> a
		a := pair.a
		b := pair.b
		append(&adj[a], b)
		append(&adj[b], a)
	}
	fmt.println("adj after: ", adj)
	fmt.println()
	fmt.println()
	fmt.println()
	fmt.println()

	sum2 := mutationMin(adj, portals)

	res := sum - sum2
	fmt.printfln("res: %d", res)


}

mutationMin :: proc(adj: map[int][dynamic]int, portals: int) -> int {
	minValue := 999_999_999_999
	for i := 1; i <= portals; i += 1 {
		a := i
		for b := 5; b <= portals; b += 1 {
			if abs(a - b) < 3 {
				continue
			}

			append(&adj[a], b)
			append(&adj[b], a)

			sum2 := 0
			for i in 1 ..= portals {
				v := getTeleportationSum2(adj, i)
				sum2 += v
			}
			// fmt.printfln("sum2: %d", sum2)
			if sum2 < minValue {
				minValue = sum2
			}

			for i := len(adj[a]) - 1; i >= 0; i -= 1 {
				v := adj[a][i]
				if v == b {
					ordered_remove(&adj[a], i)
					break
				}
			}
			for i := len(adj[b]) - 1; i >= 0; i -= 1 {
				v := adj[b][i]
				if v == a {
					ordered_remove(&adj[b], i)
					break
				}
			}
		}
	}
	fmt.printfln("min: %d", minValue)
	return minValue
}

getTeleportationSum2 :: proc(adj: map[int][dynamic]int, start: int) -> int {

	//key=portal value=steps
	seen := make(map[int]int)
	defer delete(seen)
	seen[start] = 0

	q: queue.Queue(Node)
	queue.init(&q)
	defer queue.destroy(&q)
	queue.enqueue(&q, Node{portal = start, steps = 0})

	for queue.len(q) > 0 {
		cur := queue.dequeue(&q)

		newSteps := cur.steps + 1
		for neighbour in adj[cur.portal] {
			if neighbour in seen {
				continue
			}
			seen[neighbour] = newSteps

			n := Node {
				portal = neighbour,
				steps  = newSteps,
			}
			queue.enqueue(&q, n)
		}
	}
	delete_key(&seen, start)
	sum := 0
	for _, value in seen {
		sum += value
	}
	// fmt.printfln("sum: %d res: %v \n", sum, seen)
	return sum
}

calcIndex :: proc(i: int, l: int) -> int {
	if i == 0 {
		return l
	}
	if i < 0 {
		a := abs(i)
		return l - a
	}
	if i > l {
		return i % l
	}
	return i
}

part3 :: proc() {
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
	connections := make([dynamic]Pair, arena_alloc)
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
			strs := strings.split(line, " ")
			a, _ := strconv.parse_int(strs[0])
			b, _ := strconv.parse_int(strs[1])
			append(&connections, Pair{a, b})
		}
		// fmt.println(line)
	}
	fmt.printfln("portals: %d connections: %v", portals, connections)
	//3 nearest protals
	adj := make(map[int][dynamic]int, arena_alloc)
	// adj[1] = make([dynamic]int, 0, 3)
	// append(&adj[1], 2, portals)
	//
	// adj[portals] = make([dynamic]int, 0, 3)
	// append(&adj[portals], portals - 1, 1)

	for i := 1; i <= portals; i += 1 {
		prev1 := calcIndex(i - 1, portals)
		prev2 := calcIndex(i - 2, portals)
		prev3 := calcIndex(i - 3, portals)
		cur := i
		next1 := calcIndex(i + 1, portals)
		next2 := calcIndex(i + 2, portals)
		next3 := calcIndex(i + 3, portals)
		adj[cur] = make([dynamic]int, arena_alloc)
		s := []int{prev3, prev2, prev1, next3, next2, next1}
		for i := len(s) - 1; i >= 0; i -= 1 {
			if s[i] != 0 {
				append(&adj[cur], s[i])
			}
		}
	}
	delete_key(&adj, 0)
	fmt.println("adj before: ", adj)

	sum := 0
	for i in 1 ..= portals {
		v := getTeleportationSum2(adj, i)
		sum += v
	}
	fmt.printfln("sum: %d", sum)

	//now we add connections
	for pair in connections {
		//we add a -> b and b -> a
		a := pair.a
		b := pair.b
		append(&adj[a], b)
		append(&adj[b], a)
	}
	fmt.println("adj after: ", adj)
	fmt.println()
	fmt.println()
	fmt.println()
	fmt.println()

	sum2 := mutationMin(adj, portals)

	res := sum - sum2
	fmt.printfln("res: %d", res)


}
