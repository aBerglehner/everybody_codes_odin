package my_utils

import "core:fmt"

printMat :: proc(mat: $T/[][]$E) {
	fmt.println("matrix: ")
	for row in mat {
		fmt.println(row)
	}
	fmt.println()
}
