package main

import "../utils"
import "core:fmt"
import "core:mem"
import vmem "core:mem/virtual"
import "core:os"
import "core:strconv"
import "core:strings"

main :: proc() {
	part3()
}

Pos :: struct {
	row: int,
	col: int,
}

part1 :: proc() {
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)

	path := "./08/input"
	data, err := os.read_entire_file(path, arena_alloc)
	if err != nil {
		fmt.println("err reading file")
		return
	}

	mat := make([dynamic][]int, arena_alloc)
	for line in strings.split(string(data), "\n") {
		if line == "" {
			continue
		}

		strs := strings.split(line, "")
		row := make([]int, len(strs), arena_alloc)
		for s, i in strs {
			if s != "." {
				n, _ := strconv.parse_int(s)
				row[i] = n
			} else {
				row[i] = 0
			}
		}
		append(&mat, row)
		// fmt.println(line)
	}
	utils.printMatInt(mat[:])

	rows := len(mat)
	cols := len(mat[0])

	visited := make(map[Pos]bool, arena_alloc)
	overallEnergyCount := 0

	for _, rowI in mat {
		for cur, colI in mat[rowI] {
			//we also ignore 0 cols
			if cur == 0 {
				continue
			}
			curPos := Pos{rowI, colI}
			if curPos in visited {
				continue
			}
			visited[curPos] = true
			overallEnergyCount += calcEnergy(mat[:], &visited, rows, cols, rowI, colI)

		}
	}
	fmt.println("overallEnergyCount: ", overallEnergyCount)
}

calcEnergy :: proc(mat: [][]int, visited: ^map[Pos]bool, rows, cols, row, col: int) -> int {
	r := row
	c := col
	res := 0
	//we also have a cur highest -> start with 0 -> will decrease each step by -1
	curHighest := 0

	for {
		if r < 0 || r >= rows {
			break
		}
		if c < 0 || c >= cols {
			break
		}
		cur := mat[r][c]
		if cur == 0 {
			break
		}
		curPos := Pos{r, c}
		visited^[curPos] = true

		curHighest -= 1
		if cur > curHighest {
			res += 1
			curHighest = cur
		}


		//we go always +1 row +1 col -> diagonal down
		r += 1
		c += 1
	}
	return res
}

part2 :: proc() {
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)

	path := "./08/input"
	data, err := os.read_entire_file(path, arena_alloc)
	if err != nil {
		fmt.println("err reading file")
		return
	}

	mat := make([dynamic][]int, arena_alloc)
	for line in strings.split(string(data), "\n") {
		if line == "" {
			continue
		}

		strs := strings.split(line, "")
		row := make([]int, len(strs), arena_alloc)
		for s, i in strs {
			if s != "." {
				n, _ := strconv.parse_int(s)
				row[i] = n
			} else {
				row[i] = 0
			}
		}
		append(&mat, row)
		// fmt.println(line)
	}
	utils.printMatInt(mat[:])

	rows := len(mat)
	cols := len(mat[0])

	overallEnergyCount := 0

	//for dia down right
	overallEnergyCount += topLeft(mat[:], rows, cols, 1, 1, arena_alloc)
	//for right
	overallEnergyCount += topLeft(mat[:], rows, cols, 0, 2, arena_alloc)
	//for left
	overallEnergyCount += topRight(mat[:], rows, cols, 0, -2, arena_alloc)
	//for dia down left
	overallEnergyCount += topRight(mat[:], rows, cols, 1, -1, arena_alloc)
	//missing? dia up right -> start bottom left
	overallEnergyCount += bottomLeft(mat[:], rows, cols, -1, 1, arena_alloc)
	//missing? dia up left -> start bottom right
	overallEnergyCount += bottomRight(mat[:], rows, cols, -1, -1, arena_alloc)
	fmt.println("overallEnergyCount: ", overallEnergyCount)
}

topLeft :: proc(mat: [][]int, rows, cols, rMove, cMove: int, arena_alloc: mem.Allocator) -> int {
	visited := make(map[Pos]bool, arena_alloc)
	overallEnergyCount := 0

	for _, rowI in mat {
		for cur, colI in mat[rowI] {
			//we also ignore 0 cols
			if cur == 0 {
				continue
			}
			curPos := Pos{rowI, colI}
			if curPos in visited {
				continue
			}
			visited[curPos] = true
			overallEnergyCount += calcEnergyP2(mat, &visited, rows, cols, rowI, colI, rMove, cMove)

		}
	}
	fmt.printfln("rMove: %d cMove: %d overallEnergyCount: %d", rMove, cMove, overallEnergyCount)
	return overallEnergyCount
}

topRight :: proc(mat: [][]int, rows, cols, rMove, cMove: int, arena_alloc: mem.Allocator) -> int {
	visited := make(map[Pos]bool, arena_alloc)
	overallEnergyCount := 0

	for rowI := 0; rowI < len(mat); rowI += 1 {
		for colI := len(mat[rowI]) - 1; colI >= 0; colI -= 1 {
			cur := mat[rowI][colI]
			//we also ignore 0 cols
			if cur == 0 {
				continue
			}
			curPos := Pos{rowI, colI}
			if curPos in visited {
				continue
			}
			visited[curPos] = true
			overallEnergyCount += calcEnergyP2(mat, &visited, rows, cols, rowI, colI, rMove, cMove)
		}
	}
	fmt.printfln("rMove: %d cMove: %d overallEnergyCount: %d", rMove, cMove, overallEnergyCount)
	return overallEnergyCount
}

bottomLeft :: proc(
	mat: [][]int,
	rows, cols, rMove, cMove: int,
	arena_alloc: mem.Allocator,
) -> int {
	visited := make(map[Pos]bool, arena_alloc)
	overallEnergyCount := 0

	for rowI := len(mat) - 1; rowI >= 0; rowI -= 1 {
		for colI := 0; colI < len(mat[rowI]); colI += 1 {
			cur := mat[rowI][colI]
			//we also ignore 0 cols
			if cur == 0 {
				continue
			}
			curPos := Pos{rowI, colI}
			if curPos in visited {
				continue
			}
			visited[curPos] = true
			overallEnergyCount += calcEnergyP2(mat, &visited, rows, cols, rowI, colI, rMove, cMove)
		}
	}
	fmt.printfln("rMove: %d cMove: %d overallEnergyCount: %d", rMove, cMove, overallEnergyCount)
	return overallEnergyCount
}

bottomRight :: proc(
	mat: [][]int,
	rows, cols, rMove, cMove: int,
	arena_alloc: mem.Allocator,
) -> int {
	visited := make(map[Pos]bool, arena_alloc)
	overallEnergyCount := 0

	for rowI := len(mat) - 1; rowI >= 0; rowI -= 1 {
		for colI := len(mat[rowI]) - 1; colI >= 0; colI -= 1 {
			cur := mat[rowI][colI]
			//we also ignore 0 cols
			if cur == 0 {
				continue
			}
			curPos := Pos{rowI, colI}
			if curPos in visited {
				continue
			}
			visited[curPos] = true
			overallEnergyCount += calcEnergyP2(mat, &visited, rows, cols, rowI, colI, rMove, cMove)
		}
	}
	fmt.printfln("rMove: %d cMove: %d overallEnergyCount: %d", rMove, cMove, overallEnergyCount)
	return overallEnergyCount
}

calcEnergyP2 :: proc(
	mat: [][]int,
	visited: ^map[Pos]bool,
	rows, cols, row, col, rMove, cMove: int,
) -> int {
	r := row
	c := col
	res := 0
	//we also have a cur highest -> start with 0 -> will decrease each step by -1
	curHighest := 0

	for {
		if r < 0 || r >= rows {
			break
		}
		if c < 0 || c >= cols {
			break
		}
		cur := mat[r][c]
		if cur == 0 {
			break
		}
		curPos := Pos{r, c}
		visited^[curPos] = true

		curHighest -= 1
		if cur > curHighest {
			res += 1
			curHighest = cur
		}

		r += rMove
		c += cMove
	}
	return res
}

ProcInfo :: struct {
	f:     proc(_: [][]int, _: int, _: int, _: int, _: int, _: mem.Allocator) -> (int, int),
	rMove: int,
	cMove: int,
}

//899446
//length and first char is correct
part3 :: proc() {
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)

	path := "./08/input"
	data, err := os.read_entire_file(path, arena_alloc)
	if err != nil {
		fmt.println("err reading file")
		return
	}

	mat := make([dynamic][]int, arena_alloc)
	for line in strings.split(string(data), "\n") {
		if line == "" {
			continue
		}

		strs := strings.split(line, "")
		row := make([]int, len(strs), arena_alloc)
		for s, i in strs {
			if s != "." {
				n, _ := strconv.parse_int(s)
				row[i] = n
			} else {
				row[i] = 0
			}
		}
		append(&mat, row)
		// fmt.println(line)
	}
	// utils.printMatInt(mat[:])

	rows := len(mat)
	cols := len(mat[0])


	moves := [?]ProcInfo {
		ProcInfo{topLeftP3, 1, 1},
		ProcInfo{topRightP3, 1, -1},
		ProcInfo{topRightP3, 0, -2},
		ProcInfo{bottomRightP3, -1, -1},
		ProcInfo{bottomLeftP3, -1, 1},
		ProcInfo{topLeftP3, 0, 2},
	}

	overallEnergyCount := 0
	warriorsCount := 0
	round := 1
	outer: for {
		for move, i in moves {
			newWarriors, energyCount := move.f(
				mat[:],
				rows,
				cols,
				move.rMove,
				move.cMove,
				arena_alloc,
			)
			overallEnergyCount += energyCount
			warriorsCount += newWarriors
			if warriorsCount >= 100000 {
				fmt.printfln(
					"round: %d rMove: %d cMove: %d overallEnergyCount: %d warriorsCount: %d",
					round,
					move.rMove,
					move.cMove,
					overallEnergyCount,
					warriorsCount,
				)
				break outer
			}
			// utils.printMatInt(mat[:])
			round += 1
		}
	}

}

topLeftP3 :: proc(
	mat: [][]int,
	rows, cols, rMove, cMove: int,
	arena_alloc: mem.Allocator,
) -> (
	int,
	int,
) {
	visited := make(map[Pos]bool, arena_alloc)
	overallEnergyCount := 0
	warriorsCount := 0

	for _, rowI in mat {
		for cur, colI in mat[rowI] {
			//we also ignore 0 cols
			if cur == 0 {
				continue
			}
			curPos := Pos{rowI, colI}
			if curPos in visited {
				continue
			}
			if cur == -1 {
				mat[rowI][colI] = 1
			} else if cur < -1 {
				mat[rowI][colI] = cur + 1
			}
			visited[curPos] = true
			newWarriors, energyCount := calcEnergyP3(
				mat,
				&visited,
				rows,
				cols,
				rowI,
				colI,
				rMove,
				cMove,
			)
			overallEnergyCount += energyCount
			warriorsCount += newWarriors

		}
	}
	return warriorsCount, overallEnergyCount
}

topRightP3 :: proc(
	mat: [][]int,
	rows, cols, rMove, cMove: int,
	arena_alloc: mem.Allocator,
) -> (
	int,
	int,
) {
	visited := make(map[Pos]bool, arena_alloc)
	overallEnergyCount := 0
	warriorsCount := 0

	for rowI := 0; rowI < len(mat); rowI += 1 {
		for colI := len(mat[rowI]) - 1; colI >= 0; colI -= 1 {
			cur := mat[rowI][colI]
			//we also ignore 0 cols
			if cur == 0 {
				continue
			}
			curPos := Pos{rowI, colI}
			if curPos in visited {
				continue
			}
			if cur == -1 {
				mat[rowI][colI] = 1
			} else if cur < -1 {
				mat[rowI][colI] = cur + 1
			}
			visited[curPos] = true
			newWarriors, energyCount := calcEnergyP3(
				mat,
				&visited,
				rows,
				cols,
				rowI,
				colI,
				rMove,
				cMove,
			)
			overallEnergyCount += energyCount
			warriorsCount += newWarriors

		}
	}
	return warriorsCount, overallEnergyCount
}

bottomLeftP3 :: proc(
	mat: [][]int,
	rows, cols, rMove, cMove: int,
	arena_alloc: mem.Allocator,
) -> (
	int,
	int,
) {
	visited := make(map[Pos]bool, arena_alloc)
	overallEnergyCount := 0
	warriorsCount := 0

	for rowI := len(mat) - 1; rowI >= 0; rowI -= 1 {
		for colI := 0; colI < len(mat[rowI]); colI += 1 {
			cur := mat[rowI][colI]
			//we also ignore 0 cols
			if cur == 0 {
				continue
			}
			curPos := Pos{rowI, colI}
			if curPos in visited {
				continue
			}
			if cur == -1 {
				mat[rowI][colI] = 1
			} else if cur < -1 {
				mat[rowI][colI] = cur + 1
			}
			visited[curPos] = true
			newWarriors, energyCount := calcEnergyP3(
				mat,
				&visited,
				rows,
				cols,
				rowI,
				colI,
				rMove,
				cMove,
			)
			overallEnergyCount += energyCount
			warriorsCount += newWarriors

		}
	}
	return warriorsCount, overallEnergyCount
}

bottomRightP3 :: proc(
	mat: [][]int,
	rows, cols, rMove, cMove: int,
	arena_alloc: mem.Allocator,
) -> (
	int,
	int,
) {
	visited := make(map[Pos]bool, arena_alloc)
	overallEnergyCount := 0
	warriorsCount := 0

	for rowI := len(mat) - 1; rowI >= 0; rowI -= 1 {
		for colI := len(mat[rowI]) - 1; colI >= 0; colI -= 1 {
			cur := mat[rowI][colI]
			//we also ignore 0 cols
			if cur == 0 {
				continue
			}
			curPos := Pos{rowI, colI}
			if curPos in visited {
				continue
			}
			if cur == -1 {
				mat[rowI][colI] = 1
			} else if cur < -1 {
				mat[rowI][colI] = cur + 1
			}
			visited[curPos] = true
			newWarriors, energyCount := calcEnergyP3(
				mat,
				&visited,
				rows,
				cols,
				rowI,
				colI,
				rMove,
				cMove,
			)
			overallEnergyCount += energyCount
			warriorsCount += newWarriors

		}
	}
	return warriorsCount, overallEnergyCount
}

calcEnergyP3 :: proc(
	mat: [][]int,
	visited: ^map[Pos]bool,
	rows, cols, row, col, rMove, cMove: int,
) -> (
	int,
	int,
) {
	r := row
	c := col
	res := 0
	//we also have a cur highest -> start with 0 -> will decrease each step by -1
	curHighest := 0
	newWarriors := 0

	for {
		if r < 0 || r >= rows {
			break
		}
		if c < 0 || c >= cols {
			break
		}
		cur := mat[r][c]
		if cur == 0 {
			break
		}
		curPos := Pos{r, c}

		if !(curPos in visited) {
			if cur == -1 {
				mat[r][c] = 1
			} else if cur < -1 {
				mat[r][c] = cur + 1
			}
			cur = mat[r][c]
		}
		visited^[curPos] = true

		curHighest -= 1
		if cur > 0 && cur > curHighest {
			res += 1
			curHighest = cur
			if cur == 9 {
				newWarriors += 1
				mat[r][c] = -4
			} else {
				mat[r][c] = cur + 1
			}
		}

		r += rMove
		c += cMove
	}
	return newWarriors, res
}
