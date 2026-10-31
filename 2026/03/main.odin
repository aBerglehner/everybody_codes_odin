package main

import "core:fmt"
import "core:math"
import "core:os"
import "core:strings"

main :: proc() {
	part2()
}

part1 :: proc() {
	path := "./03/input"
	data, err := os.read_entire_file(path, context.allocator)
	if err != nil {
		fmt.println("err reading file")
		return
	}

	sum := 0
	for line in strings.split(string(data), "\n") {
		if line == "" {
			continue
		}
		minusIndex := strings.index(line, "-")
		newStr, _ := strings.substring(line, minusIndex + 1, len(line))
		strs := strings.split(newStr, " ")

		iso := strs[0]
		vote := strs[1]
		fmt.printfln("iso: %s vote: %s", iso, vote)

		//loop reverse over iso and vote
		//iso (iso[i] square index) * vote[i]
		res := 0
		for i, index := len(iso) - 1, 0; i >= 0; i -= 1 {
			isoNum := int(iso[i] - 48)
			isoPow := math.pow(f32(isoNum), f32(index))
			voteNum := int(vote[i] - 48)
			num := int(isoPow) * voteNum
			res += num
			// fmt.println(num)
			index += 1
		}
		sum += res
		fmt.printfln("res: %d", res)
	}
	fmt.printfln("sum: %d", sum)


}

//29_302_324_689 -> first char correct and len correct
part2 :: proc() {
	path := "./03/test"
	data, err := os.read_entire_file(path, context.allocator)
	if err != nil {
		fmt.println("err reading file")
		return
	}

	sum := 0
	for line in strings.split(string(data), "\n") {
		if line == "" {
			continue
		}
		minusIndex := strings.index(line, "-")
		newStr, _ := strings.substring(line, minusIndex + 1, len(line))
		strs := strings.split(newStr, " ")

		iso := strs[0]
		vote := strs[1]
		fmt.printfln("iso: %s vote: %s", iso, vote)

		iso = expandIsoStr(iso, len(vote))
		fmt.println("new iso:", iso)

		//if iso is smaller than number repeat iso
		//if number is small than iso go only as far as number
		//
		//so duplicate iso as often as needed
		//than take vote as loop bound

		//loop reverse over iso and vote
		//iso (iso[i] square index) * vote[i]

		res := 0
		for i, index := len(vote) - 1, 0; i >= 0; i -= 1 {
			isoNum := int(iso[i] - 48)
			isoPow := math.pow(f32(isoNum), f32(index))
			voteNum := int(vote[i] - 48)
			num := int(isoPow) * voteNum
			res += num
			// fmt.println(num)
			index += 1
		}
		sum += res
		fmt.printfln("res: %d \n", res)
	}
	fmt.printfln("sum: %d", sum)
}

expandIsoStr :: proc(iso: string, lenNeeded: int) -> string {
	if len(iso) == lenNeeded {
		return iso
	}
	if len(iso) > lenNeeded {
		toCut := len(iso) - lenNeeded
		newStr, _ := strings.substring(iso, toCut, len(iso))
		return strings.clone(newStr)
	}
	builder := strings.builder_make()
	defer strings.builder_destroy(&builder)

	for strings.builder_len(builder) < lenNeeded {
		// fmt.println(strings.builder_len(builder))
		strings.write_string(&builder, iso)
	}
	result := strings.to_string(builder)
	toCut := len(result) - lenNeeded
	newStr, _ := strings.substring(result, toCut, len(result))
	// fmt.printfln("result: %s newStr: %s", result, newStr)
	return strings.clone(newStr)
}
