package main

import "core:container/queue"
import "core:fmt"
import "core:mem"
import vmem "core:mem/virtual"
import "core:os"
import "core:strconv"
import "core:strings"

main :: proc() {
	part3()
}

Node :: struct {
	id:          int,
	energy:      int,
	connections: []int,
}

Visit :: struct {
	id:     int,
	energy: int,
}

Tracker :: struct {
	id:    int,
	count: int,
}

part1 :: proc() {
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)

	path := "./07/input"
	data, err := os.read_entire_file(path, arena_alloc)
	if err != nil {
		fmt.println("err reading file")
		return
	}

	energyById := make(map[int]int, arena_alloc)
	connectionsById := make(map[int][]int, arena_alloc)
	mostConnections := Tracker{}
	for line in strings.split(string(data), "\n") {
		if line == "" {
			continue
		}
		node := Node{}
		for s in strings.split(line, ", ") {
			key_value := strings.split(s, "=")
			key := key_value[0]
			value := key_value[1]

			switch key {
			case "id":
				n, _ := strconv.parse_int(value)
				node.id = n
			case "energy":
				n, _ := strconv.parse_int(value)
				node.energy = n
			case "connections":
				conns := make([dynamic]int, arena_alloc)
				for v in strings.split(value, ",") {
					n, _ := strconv.parse_int(v)
					append(&conns, n)
				}
				node.connections = conns[:]
			}
		}
		conns := len(node.connections)
		if conns > mostConnections.count {
			mostConnections.count = conns
			mostConnections.id = node.id
		}

		energyById[node.id] = node.energy
		connectionsById[node.id] = node.connections
	}
	fmt.printfln(
		"energyById: %v connectionsById: %v mostConnections: %v",
		energyById,
		connectionsById,
		mostConnections,
	)

	//we start with 5 energy
	startEnergy := 5
	//start is the id with the most connections out
	//add to energyById the energy when reached it
	//decrease cur_energy -1 for every round
	//visit every connection next

	q: queue.Queue(Visit)
	queue.init(&q)
	defer queue.destroy(&q)
	queue.enqueue(&q, Visit{id = mostConnections.id, energy = startEnergy})

	for queue.len(q) > 0 {
		cur := queue.dequeue(&q)
		//add energy
		energyById[cur.id] = energyById[cur.id] + cur.energy

		nextEnergy := cur.energy - 1
		if nextEnergy == 0 {
			continue
		}
		for connectionId in connectionsById[cur.id] {
			queue.enqueue(&q, Visit{connectionId, nextEnergy})
		}
	}

	fmt.printfln("energyById: %v", energyById)

	res := 0
	for _, value in energyById {
		res += value
	}
	fmt.println("res: ", res)

}

part2 :: proc() {
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)

	path := "./07/input"
	data, err := os.read_entire_file(path, arena_alloc)
	if err != nil {
		fmt.println("err reading file")
		return
	}

	energyById := make(map[int]int, arena_alloc)
	connectionsById := make(map[int][]int, arena_alloc)
	mostConnections := Tracker{}
	for line in strings.split(string(data), "\n") {
		if line == "" {
			continue
		}
		node := Node{}
		for s in strings.split(line, ", ") {
			key_value := strings.split(s, "=")
			key := key_value[0]
			value := key_value[1]

			switch key {
			case "id":
				n, _ := strconv.parse_int(value)
				node.id = n
			case "energy":
				n, _ := strconv.parse_int(value)
				node.energy = n
			case "connections":
				conns := make([dynamic]int, arena_alloc)
				for v in strings.split(value, ",") {
					n, _ := strconv.parse_int(v)
					append(&conns, n)
				}
				node.connections = conns[:]
			}
		}
		conns := len(node.connections)
		if conns > mostConnections.count {
			mostConnections.count = conns
			mostConnections.id = node.id
		}

		energyById[node.id] = node.energy
		connectionsById[node.id] = node.connections
	}
	fmt.printfln(
		"energyById: %v connectionsById: %v mostConnections: %v",
		energyById,
		connectionsById,
		mostConnections,
	)

	startEnergy := 10

	q: queue.Queue(Visit)
	queue.init(&q, 1000)
	defer queue.destroy(&q)
	queue.enqueue(&q, Visit{id = mostConnections.id, energy = startEnergy})

	for queue.len(q) > 0 {
		cur := queue.dequeue(&q)
		//add energy
		energyById[cur.id] = energyById[cur.id] + cur.energy

		nextEnergy := cur.energy - 1
		if nextEnergy == 0 {
			continue
		}
		for connectionId in connectionsById[cur.id] {
			queue.enqueue(&q, Visit{connectionId, nextEnergy})
		}
	}

	fmt.printfln("energyById: %v", energyById)

	res := 0
	for _, value in energyById {
		res += value
	}
	fmt.println("res: ", res)

}

part3 :: proc() {
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)

	path := "./07/test"
	data, err := os.read_entire_file(path, arena_alloc)
	if err != nil {
		fmt.println("err reading file")
		return
	}

	energyById := make(map[int]int, arena_alloc)
	connectionsById := make(map[int][]int, arena_alloc)
	mostConnections := Tracker{}
	for line in strings.split(string(data), "\n") {
		if line == "" {
			continue
		}
		node := Node{}
		for s in strings.split(line, ", ") {
			key_value := strings.split(s, "=")
			key := key_value[0]
			value := key_value[1]

			switch key {
			case "id":
				n, _ := strconv.parse_int(value)
				node.id = n
			case "energy":
				n, _ := strconv.parse_int(value)
				node.energy = n
			case "connections":
				conns := make([dynamic]int, arena_alloc)
				for v in strings.split(value, ",") {
					n, _ := strconv.parse_int(v)
					append(&conns, n)
				}
				node.connections = conns[:]
			}
		}
		conns := len(node.connections)
		if conns > mostConnections.count {
			mostConnections.count = conns
			mostConnections.id = node.id
		}

		energyById[node.id] = node.energy
		connectionsById[node.id] = node.connections
	}
	fmt.printfln(
		"energyById: %v connectionsById: %v mostConnections: %v",
		energyById,
		connectionsById,
		mostConnections,
	)

	startEnergy := 10
	explosionLimit := 100

	q: queue.Queue(Visit)
	queue.init(&q, 1000)
	defer queue.destroy(&q)
	queue.enqueue(&q, Visit{id = 2, energy = startEnergy})

	alreadyDestroyed := make(map[int]bool, arena_alloc)

	for queue.len(q) > 0 {
		cur := queue.dequeue(&q)
		if cur.id in alreadyDestroyed {
			continue
		}
		//if curEnergy is >= explosionLimit -> destroy it, and queue connections with energy 10
		addedEnergy := energyById[cur.id] + cur.energy

		if addedEnergy >= explosionLimit {
			alreadyDestroyed[cur.id] = true
			delete_key(&energyById, cur.id)
			for connectionId in connectionsById[cur.id] {
				queue.enqueue(&q, Visit{connectionId, startEnergy})
			}
		}

		//add energy
		energyById[cur.id] = addedEnergy

		nextEnergy := cur.energy - 1
		if nextEnergy == 0 {
			continue
		}
		for connectionId in connectionsById[cur.id] {
			queue.enqueue(&q, Visit{connectionId, nextEnergy})
		}
	}

	fmt.printfln("energyById: %v", energyById)

	res := 0
	for _, value in energyById {
		res += value
	}
	fmt.println("res: ", res)

}
