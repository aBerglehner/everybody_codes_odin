package main

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"

main :: proc() {
	part1()
}

//sort each line by a pair
//this works for part1, part2 and part3
part1 :: proc() {
	path := "./02/input"
	data, err := os.read_entire_file(path, context.allocator)
	if err != nil {
		fmt.println("err reading file")
		return
	}

	lines: [dynamic][]string
	defer delete(lines)
	for line in strings.split(string(data), "\n") {
		if line == "" {
			continue
		}
		// fmt.println(line)
		parts := strings.split(string(line), " ")

		append(&lines, parts)
	}
	// fmt.println(lines)

	sum := 0
	for line in lines {
		list := make([dynamic]int)
		//init list with all values. Make sure they are distinct
		//3,5,1,2,4
		for key in line {
			// fmt.printfln("key: %s", key)
			a := int(key[0] - 48)
			if !slice.contains(list[:], a) {
				append(&list, a)
			}
			b := int(key[2] - 48)
			// fmt.printfln("a: %d b: %d", a, b)
			if !slice.contains(list[:], b) {
				append(&list, b)
			}
		}
		fmt.printfln("list before sort: %v", list)

		for {
			needsSort := false
			for key in line {
				// fmt.printfln("key: %s", key)
				b := sortList(list[:], key)
				if b {
					needsSort = true
				}
			}

			if !needsSort {
				break
			}
		}

		fmt.printfln("list after  sort: %v", list)
		fmt.println("---")

		sum += sumListAsString(list[:])

		delete(list)
	}
	fmt.printfln("sum: %d", sum)

}

sumListAsString :: proc(list: []int) -> int {
	res := 0
	for n in list {
		res = res * 10 + n
	}
	return res
}

//key is in list
sortList :: proc(list: []int, key: string) -> bool {
	a := int(key[0] - 48)
	comp := key[1]
	b := int(key[2] - 48)
	aIndex := findIndex(list, a)
	bIndex := findIndex(list, b)
	// fmt.println(comp)

	if comp == '>' {
		if aIndex > bIndex {
			list[aIndex], list[bIndex] = list[bIndex], list[aIndex]
			return true
		}
	}
	//4<3 -> 4 needs to come before 3
	if comp == '<' {
		if aIndex < bIndex {
			list[aIndex], list[bIndex] = list[bIndex], list[aIndex]
			return true
		}
	}
	return false
}

findIndex :: proc(list: []int, searched: int) -> int {
	for value, i in list {
		if value == searched {
			return i
		}
	}
	return -1
}
