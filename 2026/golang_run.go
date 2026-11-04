package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

type Node struct {
	id          int
	energy      int
	connections []int
}

type Visit struct {
	id     int
	energy int
}

type Tracker struct {
	id    int
	count int
}

func main() {
	path := "./07/input"

	data, err := os.ReadFile(path)
	if err != nil {
		fmt.Println("err reading file:", err)
		return
	}

	energyByID := make(map[int]int)
	connectionsByID := make(map[int][]int)
	mostConnections := Tracker{}

	// Parse input
	for _, line := range strings.Split(string(data), "\n") {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}

		node := Node{}

		for _, s := range strings.Split(line, ", ") {
			keyValue := strings.SplitN(s, "=", 2)
			if len(keyValue) != 2 {
				continue
			}

			key := keyValue[0]
			value := keyValue[1]

			switch key {
			case "id":
				node.id, _ = strconv.Atoi(value)

			case "energy":
				node.energy, _ = strconv.Atoi(value)

			case "connections":
				for _, v := range strings.Split(value, ",") {
					n, _ := strconv.Atoi(v)
					node.connections = append(node.connections, n)
				}
			}
		}

		conns := len(node.connections)
		if conns > mostConnections.count {
			mostConnections.count = conns
			mostConnections.id = node.id
		}

		energyByID[node.id] = node.energy
		connectionsByID[node.id] = node.connections
	}

	fmt.Println("energyByID:", energyByID)
	fmt.Println("connectionsByID:", connectionsByID)
	fmt.Println("mostConnections:", mostConnections)

	startEnergy := 10

	// BFS using a queue
	queue := []Visit{
		{id: mostConnections.id, energy: startEnergy},
	}

	for len(queue) > 0 {
		cur := queue[0]
		queue = queue[1:]

		// Add energy
		energyByID[cur.id] += cur.energy

		nextEnergy := cur.energy - 1
		if nextEnergy == 0 {
			continue
		}

		for _, connectionID := range connectionsByID[cur.id] {
			queue = append(queue, Visit{
				id:     connectionID,
				energy: nextEnergy,
			})
		}
	}

	fmt.Println("energyByID:", energyByID)

	res := 0
	for _, value := range energyByID {
		res += value
	}

	fmt.Println("res:", res)
}
