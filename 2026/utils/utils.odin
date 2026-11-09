package my_utils

import "core:fmt"

Pos :: struct {
	r: int,
	c: int,
}

//$T/Some_Type	Polymorphic parameter constrained by a type pattern. $E is the type
printMat :: proc(mat: $T/[][]$E) {
	fmt.println("matrix: ")
	for row in mat {
		fmt.println(row)
	}
	fmt.println()
}
