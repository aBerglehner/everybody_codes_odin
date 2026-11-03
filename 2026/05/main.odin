package main

import "core:fmt"
import "core:mem"
import vmem "core:mem/virtual"
import "core:os"
import "core:strconv"
import "core:strings"

main :: proc() {
	part2()
}

Pos :: struct {
	row: int,
	col: int,
}

dirs := [8]Pos {
	//up
	Pos{-1, 0},
	//down
	Pos{1, 0},
	//right
	Pos{0, 1},
	//left
	Pos{0, -1},
	//up right
	Pos{-1, 1},
	//up left
	Pos{-1, -1},
	//down left
	Pos{1, -1},
	//down right
	Pos{1, 1},
}

part1 :: proc() {
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)

	path := "./05/input"
	data, err := os.read_entire_file(path, arena_alloc)
	if err != nil {
		fmt.println("err reading file")
		return
	}

	mat := make([dynamic][]i8, arena_alloc)
	for line in strings.split(string(data), "\n") {
		if line == "" {
			continue
		}
		strs := strings.split(line, "")
		nums := make([dynamic]i8, len(strs), arena_alloc)
		for s, i in strs {
			n, _ := strconv.parse_int(s)
			nums[i] = i8(n)
		}
		append(&mat, nums[:])
		// fmt.println(line)
	}

	rows := len(mat)
	cols := len(mat[0])
	midRow := rows / 2
	midCol := cols / 2
	fmt.printfln("rows: %v cols: %v midRow: %d midCol: %d", rows, cols, midRow, midCol)
	//1. find middle and set it to # ->3
	mat[midRow][midCol] = 7

	for row in mat {
		fmt.println(row)
	}

	for i in 1 ..= 123 {
		neighbours := findNeighbour(mat[:], rows, cols, arena_alloc)
		newMat := copyMatrix(mat[:], arena_alloc)

		//4. keep track of new land -> otherwise we are done
		newLand := false
		//3.1 loop over neighbours and check as long as always 1 has changed to 7
		for nb in neighbours {
			//3.2 5 neighbours needs to be 7 or 1 -> than set itself to 7
			if countLand(mat[:], rows, cols, nb.row, nb.col) >= 5 {
				newMat[nb.row][nb.col] = 7
				newLand = true
			}
		}
		mat = newMat

		if !newLand {
			break
		}

		// fmt.println("---")
		// fmt.println("after i: ", i)
		// fmt.println("---")
		// for row in mat {
		// 	fmt.println(row)
		// }
	}

	for row in mat {
		fmt.println(row)
	}

	res := 0
	for _, rowI in mat {
		for col in mat[rowI] {
			if col == 7 {
				res += 1
			}
		}
	}
	fmt.println("res: ", res)

}

findNeighbour :: proc(mat: [][]i8, rows: int, cols: int, arena_alloc: mem.Allocator) -> []Pos {
	//2. find every neighbour cell of 7 which is itself not 7
	neighbours := make([dynamic]Pos, arena_alloc)
	for _, rowI in mat {
		for _, colI in mat[rowI] {
			if isNeighbour(mat[:], rows, cols, rowI, colI) {
				append(&neighbours, Pos{rowI, colI})
			}
		}
	}
	return neighbours[:]
}

isNeighbour :: proc(mat: [][]i8, rows: int, cols: int, row: int, col: int) -> bool {
	for dir in dirs {
		rr := dir.row + row
		if rr < 0 || rr >= rows {
			continue
		}
		cc := dir.col + col
		if cc < 0 || cc >= cols {
			continue
		}
		if mat[row][col] == 7 {
			continue
		}

		if mat[rr][cc] == 7 {
			return true
		}
	}
	return false
}

countLand :: proc(mat: [][]i8, rows: int, cols: int, row: int, col: int) -> int {
	res := 0
	for dir in dirs {
		rr := dir.row + row
		if rr < 0 || rr >= rows {
			continue
		}
		cc := dir.col + col
		if cc < 0 || cc >= cols {
			continue
		}
		if mat[row][col] == 7 {
			continue
		}

		if mat[rr][cc] == 7 || mat[rr][cc] == 1 {
			res += 1
		}
	}
	return res
}

copyMatrix :: proc(src: [][]i8, alloc: mem.Allocator) -> [dynamic][]i8 {
	dst := make([dynamic][]i8, len(src), alloc)

	for i in 0 ..< len(src) {
		dst[i] = make([]i8, len(src[i]), alloc)
		copy(dst[i], src[i])
	}

	return dst
}

part2 :: proc() {
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)

	path := "./05/input"
	data, err := os.read_entire_file(path, arena_alloc)
	if err != nil {
		fmt.println("err reading file")
		return
	}

	mat := make([dynamic][]i8, arena_alloc)
	for line in strings.split(string(data), "\n") {
		if line == "" {
			continue
		}
		strs := strings.split(line, "")
		nums := make([dynamic]i8, len(strs), arena_alloc)
		for s, i in strs {
			n, _ := strconv.parse_int(s)
			nums[i] = i8(n)
		}
		append(&mat, nums[:])
		// fmt.println(line)
	}

	rows := len(mat)
	cols := len(mat[0])
	midRow := rows / 2
	midCol := cols / 2
	fmt.printfln("rows: %v cols: %v midRow: %d midCol: %d", rows, cols, midRow, midCol)
	//1. find middle and set it to # ->3
	mat[midRow][midCol] = 7

	for row in mat {
		fmt.println(row)
	}

	for i in 1 ..= 12300000 {
		neighbours := findNeighbour(mat[:], rows, cols, arena_alloc)
		newMat := copyMatrix(mat[:], arena_alloc)

		//4. keep track of new land -> otherwise we are done
		newLand := false
		//3.1 loop over neighbours and check as long as always 1 has changed to 7
		for nb in neighbours {
			//3.2 5 neighbours needs to be 7 or 1 -> than set itself to 7
			if countLand(mat[:], rows, cols, nb.row, nb.col) >= 5 {
				newMat[nb.row][nb.col] = 7
				newLand = true
			}
		}
		mat = newMat

		if !newLand {
			break
		}

		// fmt.println("---")
		// fmt.println("after i: ", i)
		// fmt.println("---")
		// for row in mat {
		// 	fmt.println(row)
		// }
	}

	fmt.println()
	fmt.println()
	for row in mat {
		fmt.println(row)
	}
	fmt.println()
	fmt.println()
	fmt.println("----")
	fmt.println("mark water as 9 and every land cell adjacent to water becomes sand 8")
	fmt.println()

	//mark water as 9
	for _, rowI in mat {
		for col, colI in mat[rowI] {
			if col != 7 {
				mat[rowI][colI] = 9
			}
		}
	}

	//every land cell adjacent to water becomes sand -> 8
	for _, rowI in mat {
		for col, colI in mat[rowI] {
			if isWaterNeighbour(mat[:], rows, cols, rowI, colI) {
				mat[rowI][colI] = 8
			}
		}
	}

	for row in mat {
		fmt.println(row)
	}
	fmt.println()
	fmt.println()

	for i in 1 ..= 12300000 {
		neighbours := findSandNeighbour(mat[:], rows, cols, arena_alloc)
		newMat := copyMatrix(mat[:], arena_alloc)

		newSand := false
		for nb in neighbours {
			if countSand(mat[:], rows, cols, nb.row, nb.col) >= 5 {
				newMat[nb.row][nb.col] = 8
				newSand = true
			}
		}
		mat = newMat

		if !newSand {
			break
		}

		// fmt.println("---")
		// fmt.println("after i: ", i)
		// fmt.println("---")
		// for row in mat {
		// 	fmt.println(row)
		// }
	}

	fmt.println("after sand mark")
	fmt.println()
	for row in mat {
		fmt.println(row)
	}


	res := 0
	for _, rowI in mat {
		for col in mat[rowI] {
			if col == 8 {
				res += 1
			}
		}
	}
	fmt.println("res: ", res)
}

isWaterNeighbour :: proc(mat: [][]i8, rows: int, cols: int, row: int, col: int) -> bool {
	for dir in dirs {
		rr := dir.row + row
		if rr < 0 || rr >= rows {
			continue
		}
		cc := dir.col + col
		if cc < 0 || cc >= cols {
			continue
		}
		//water is 9
		if mat[row][col] == 9 {
			continue
		}

		// edge cells also will be marked as sand
		if rr == 0 || cc == 0 || rr == rows - 1 || cc == cols - 1 {
			return true
		}

		if mat[rr][cc] == 9 {
			return true
		}
	}
	return false
}


findSandNeighbour :: proc(mat: [][]i8, rows: int, cols: int, arena_alloc: mem.Allocator) -> []Pos {
	neighbours := make([dynamic]Pos, arena_alloc)
	for _, rowI in mat {
		for _, colI in mat[rowI] {
			if isSandNeighbour(mat[:], rows, cols, rowI, colI) {
				append(&neighbours, Pos{rowI, colI})
			}
		}
	}
	return neighbours[:]
}

isSandNeighbour :: proc(mat: [][]i8, rows: int, cols: int, row: int, col: int) -> bool {
	for dir in dirs {
		rr := dir.row + row
		if rr < 0 || rr >= rows {
			continue
		}
		cc := dir.col + col
		if cc < 0 || cc >= cols {
			continue
		}
		//sand is 8
		if mat[row][col] == 8 {
			continue
		}

		if mat[rr][cc] == 8 {
			return true
		}
	}
	return false
}

countSand :: proc(mat: [][]i8, rows: int, cols: int, row: int, col: int) -> int {
	res := 0
	for dir in dirs {
		rr := dir.row + row
		if rr < 0 || rr >= rows {
			continue
		}
		cc := dir.col + col
		if cc < 0 || cc >= cols {
			continue
		}
		//sand is 8
		if mat[row][col] == 8 {
			continue
		}

		if mat[rr][cc] == 8 {
			res += 1
		}
	}
	return res
}
