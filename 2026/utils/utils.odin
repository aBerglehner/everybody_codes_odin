package my_utils

import "core:fmt"

printMatInt :: proc(mat: [][]int) {
	fmt.println("matrix: ")
	for row in mat {
		fmt.println(row)
	}
	fmt.println()
}
