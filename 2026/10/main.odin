package main

import "../utils"
import "core:fmt"
import vmem "core:mem/virtual"
import "core:os"
import "core:slice"
import "core:strings"

main :: proc() {
	part3()
}


Ghost :: struct {
	dir:   string,
	r:     int,
	c:     int,
	colls: int,
	alive: bool,
}

part1 :: proc() {
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)

	path := "./10/input"
	data, err := os.read_entire_file(path, arena_alloc)
	if err != nil {
		fmt.println("err reading file")
		return
	}


	mat := make([dynamic][]string, arena_alloc)
	for line in strings.split(string(data), "\n") {
		if line == "" {
			continue
		}
		fmt.println(line)
		append(&mat, strings.split(line, ""))
	}
	utils.printMat(mat[:])

	dirs := [?]string{"^", ">", "v", "<"}
	// d1 := nextDir(dirs[:], "<", 1)
	// d2 := nextDir(dirs[:], "<", 2)
	// d3 := nextDir(dirs[:], "v", 1)
	// fmt.printfln("d1: %s d2: %s d3: %s", d1, d2, d3)

	// # -> wall, . -> free space, ^>v< -> dirs
	//get matrix
	//track every ghost
	ghosts := make([dynamic]Ghost, arena_alloc)
	for _, rowI in mat {
		for cur, colI in mat[rowI] {
			if slice.contains(dirs[:], cur) {
				ghost := Ghost{cur, rowI, colI, 0, true}
				append(&ghosts, ghost)
			}
		}
	}
	fmt.println("ghosts: ", ghosts)
	fmt.println("len ghosts: ", len(ghosts))

	//update ghosts
	collisions := 0
	for i in 1 ..= 10 {
		seen := make(map[utils.Pos]int)
		for &g in ghosts {
			collisions += updateGhost(mat[:], dirs[:], &g)
			p := utils.Pos{g.r, g.c}
			seen[p] = seen[p] + 1
		}
		for &g in ghosts {
			p := utils.Pos{g.r, g.c}
			//if g in seen -> nextDir 2
			if seen[p] > 1 {
				collisions += 1
				g.dir = nextDir(dirs[:], g.dir, 2)
			}
		}
		delete(seen)
		fmt.println()
		fmt.printfln("round: %d ghosts: %v, colls: %d", i, ghosts, collisions)
	}

	//after each run check all ghosts -> if same pos
	// ++collsion -> and call nextDirection twice


}

//->move +1 into direction
//->if # leave on pos but swap to next direction -> also ++collision
updateGhost :: proc(mat: [][]string, dirs: []string, ghost: ^Ghost) -> int {
	collision := 0
	pos := utils.Pos{}
	switch ghost.dir {
	case "^":
		pos = utils.Pos{-1, 0}
	case ">":
		pos = utils.Pos{0, 1}
	case "v":
		pos = utils.Pos{1, 0}
	case "<":
		pos = utils.Pos{0, -1}
	}

	rr := ghost.r + pos.r
	cc := ghost.c + pos.c
	next := mat[rr][cc]
	if next == "#" {
		collision += 1
		ghost.colls += 1
		ghost.dir = nextDir(dirs, ghost.dir, 1)
		if ghost.colls >= Colls_Limit {
			ghost.alive = false
		}
	} else {
		ghost.r = rr
		ghost.c = cc
	}

	return collision
}

nextDir :: proc(dirs: []string, curDir: string, turns: int) -> string {
	l := len(dirs)
	i, _ := slice.linear_search(dirs, curDir)
	wantedIndex := i + turns
	return dirs[wantedIndex % l]
}

//131029,130993 -> len and first is correct
part2 :: proc() {
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)

	path := "./10/input"
	data, err := os.read_entire_file(path, arena_alloc)
	if err != nil {
		fmt.println("err reading file")
		return
	}


	mat := make([dynamic][]string, arena_alloc)
	for line in strings.split(string(data), "\n") {
		if line == "" {
			continue
		}
		fmt.println(line)
		append(&mat, strings.split(line, ""))
	}
	utils.printMat(mat[:])

	dirs := [?]string{"^", ">", "v", "<"}
	// d1 := nextDir(dirs[:], "<", 1)
	// d2 := nextDir(dirs[:], "<", 2)
	// d3 := nextDir(dirs[:], "v", 1)
	// fmt.printfln("d1: %s d2: %s d3: %s", d1, d2, d3)

	// # -> wall, . -> free space, ^>v< -> dirs
	//get matrix
	//track every ghost
	ghosts := make([dynamic]Ghost, arena_alloc)
	for _, rowI in mat {
		for cur, colI in mat[rowI] {
			if slice.contains(dirs[:], cur) {
				ghost := Ghost{cur, rowI, colI, 0, true}
				append(&ghosts, ghost)
			}
		}
	}
	fmt.println("ghosts: ", ghosts)
	fmt.println("len ghosts: ", len(ghosts))

	//update ghosts
	collsLimit := 10000
	for i in 1 ..= 100_000_000 {
		seen := make(map[utils.Pos]int)
		if len(ghosts) == 0 {
			fmt.println()
			fmt.printfln("round: %d ghosts: %v", i - 1, ghosts)
			fmt.println("we broke")
			fmt.println()
			break
		}
		for &g in ghosts {
			updateGhost(mat[:], dirs[:], &g)
		}
		for i := len(ghosts) - 1; i >= 0; i -= 1 {
			g := &ghosts[i]
			if g.colls >= collsLimit {
				ordered_remove_dynamic_array(&ghosts, i)
			} else {
				p := utils.Pos{g.r, g.c}
				seen[p] = seen[p] + 1
			}
		}
		for i := len(ghosts) - 1; i >= 0; i -= 1 {
			g := &ghosts[i]
			p := utils.Pos{g.r, g.c}
			//if g in seen -> nextDir 2
			if seen[p] > 1 {
				g.colls += 1
				g.dir = nextDir(dirs[:], g.dir, 2)
			}
			if g.colls >= collsLimit {
				ordered_remove_dynamic_array(&ghosts, i)
			}
		}
		delete(seen)
		// fmt.println()
		// fmt.printfln("round: %d ghosts: %v", i, ghosts)
	}

	//after each run check all ghosts -> if same pos
	// ++collsion -> and call nextDirection twice

}

// Colls_Limit := 10000
Colls_Limit := 1_000_000_000_000

Direction :: enum {
	UP,
	RIGHT,
	DOWN,
	LEFT,
}

Ghost2 :: struct {
	colls: int,
	dir:   Direction,
	r:     i8,
	c:     i8,
}

//TODO:(Alex) perf optimize this
part3 :: proc() {
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)

	path := "./10/test"
	data, err := os.read_entire_file(path, arena_alloc)
	if err != nil {
		fmt.println("err reading file")
		return
	}


	mat := make([dynamic][]u8, arena_alloc)
	for line in strings.split(string(data), "\n") {
		if line == "" {
			continue
		}
		fmt.println(line)
		strs := strings.split(line, "")
		cU8 := make([dynamic]u8)
		for s in strs {
			append(&cU8, s[0])
		}
		append(&mat, cU8[:])
	}
	utils.printMat(mat[:])

	dirs := [?]u8{'^', '>', 'v', '<'}
	// d1 := nextDir(dirs[:], "<", 1)
	// d2 := nextDir(dirs[:], "<", 2)
	// d3 := nextDir(dirs[:], "v", 1)
	// fmt.printfln("d1: %s d2: %s d3: %s", d1, d2, d3)

	// # -> wall, . -> free space, ^>v< -> dirs
	//get matrix
	//track every ghost
	ghosts := make([dynamic]Ghost2, arena_alloc)
	for _, rowI in mat {
		for cur, colI in mat[rowI] {
			if slice.contains(dirs[:], cur) {
				d := getDirection(cur)
				ghost := Ghost2{0, d, i8(rowI), i8(colI)}
				append(&ghosts, ghost)
			}
		}
	}
	fmt.println("ghosts: ", ghosts)
	fmt.println("len ghosts: ", len(ghosts))

	//1_000_000_000_000
	//update ghosts
	collsLimit := 1_000_000_000_000
	seen: [30][30]i8
	generation: [30][30]int
	// seen := make(map[utils.Pos]int, arena_alloc)
	for i in 1 ..= 100_000_000_000_000 {
		if i % 10_000_000 == 0 {
			fmt.printfln("round: %d", i)
		}

		firstGhostLoop(mat[:], &ghosts, &seen, &generation, i)


		allDead := true
		for i := len(ghosts) - 1; i >= 0; i -= 1 {
			g := &ghosts[i]
			//if g in seen -> nextDir 2
			if seen[g.r][g.c] > 1 {
				g.colls += 1
				g.dir = nextDir2(g.dir, 2)
			}
			if g.colls >= Colls_Limit {
				ordered_remove_dynamic_array(&ghosts, i)
			} else {
				allDead = false
			}
		}
		if allDead {
			fmt.println()
			fmt.printfln("round: %d ghosts: %v", i, ghosts)
			fmt.println("we broke")
			fmt.println()
			break
		}

		// fmt.println()
		// fmt.printfln("round: %d ghosts: %v", i, ghosts)
	}

	//after each run check all ghosts -> if same pos
	// ++collsion -> and call nextDirection twice

}

firstGhostLoop :: proc(
	mat: [][]u8,
	ghosts: ^[dynamic]Ghost2,
	seen: ^[30][30]i8,
	generation: ^[30][30]int,
	i: int,
) {
	for i := len(ghosts) - 1; i >= 0; i -= 1 {
		g := &ghosts[i]
		alive := updateGhost2(mat, g)
		if alive == 1 {
			ordered_remove_dynamic_array(ghosts, i)
		}

		if generation[g.r][g.c] != i {
			generation[g.r][g.c] = i
			seen[g.r][g.c] = 0
		}
		seen[g.r][g.c] += 1
	}
}

dr := [4]i8{-1, 0, 1, 0}
dc := [4]i8{0, 1, 0, -1}

updateGhost2 :: proc(mat: [][]u8, ghost: ^Ghost2) -> i8 {
	rr := ghost.r + dr[ghost.dir]
	cc := ghost.c + dc[ghost.dir]

	if mat[rr][cc] == '#' {
		ghost.colls += 1
		ghost.dir = nextDir2(ghost.dir, 1)

		if ghost.colls >= Colls_Limit {
			return 1
		}
	} else {
		ghost.r = rr
		ghost.c = cc
	}
	return 0
}

nextDir2 :: proc(dir: Direction, turns: int) -> Direction {
	//bitwise & 3 == %4
	return Direction((int(dir) + turns) & 3)
}

getDirection :: proc(s: u8) -> Direction {
	switch s {
	case '^':
		return .UP
	case '>':
		return .RIGHT
	case 'v':
		return .DOWN
	case '<':
		return .LEFT
	}
	return .UP // fallback
}
