package main

import "core:fmt"
import "core:math"
import vmem "core:mem/virtual"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"


main :: proc() {
	part3()
}

part1 :: proc() {
	path := "./04/input"
	data, err := os.read_entire_file(path, context.allocator)
	if err != nil {
		fmt.println("err reading file")
		return
	}

	timeById := make(map[int]int)
	defer delete(timeById)
	for line in strings.split(string(data), "\n") {
		if line == "" {
			continue
		}
		strs := strings.split(line, " ")
		//we only need id and time for this part1
		//so index 0 = id and 3 = time
		id := getData(strs[0])
		time := getData(strs[3])
		if id in timeById {
			timeById[id] = timeById[id] + time
		} else {
			timeById[id] = time
		}

	}
	fmt.println(timeById)
	l := len(timeById)
	times := make([dynamic]int)
	defer delete(times)
	for _, value in timeById {
		append(&times, value)
	}
	slice.sort(times[:])
	fmt.println(times)

	res := 0
	for v, i in times {
		res += (i + 1) * v
	}
	fmt.println("res:", res)

}

//will be time=562 -> want 562
getData :: proc(input: string) -> int {
	equalI := strings.index(input, "=")
	res, _ := strings.substring(input, (equalI + 1), len(input))
	n, _ := strconv.parse_int(res)
	return n
}

TimeParts :: struct {
	time:  int,
	parts: int,
}

part2 :: proc() {
	path := "./04/input"
	data, err := os.read_entire_file(path, context.allocator)
	if err != nil {
		fmt.println("err reading file")
		return
	}


	timeById := make(map[int]TimeParts)
	defer delete(timeById)
	for line in strings.split(string(data), "\n") {
		if line == "" {
			continue
		}
		strs := strings.split(line, " ")
		//we only need id and time for this part1
		//so index 0 = id and 3 = time
		id := getData(strs[0])
		time := getData(strs[3])
		if id in timeById {
			a := timeById[id]
			timeById[id] = TimeParts {
				time  = a.time + time,
				parts = a.parts + 1,
			}
		} else {
			timeById[id] = TimeParts{time, 1}
		}

	}
	fmt.println("map: ", timeById)
	l := len(timeById)
	times := make([dynamic]TimeParts)
	defer delete(times)
	for _, value in timeById {
		append(&times, value)
	}
	fmt.println("before: ", times)
	slice.sort_by(times[:], compPart2)
	fmt.println("after: ", times)

	res := 0
	for v, i in times {
		res += (i + 1) * v.time
	}
	fmt.println("res:", res)


}

//first sort based on parts than on time
compPart2 :: proc(a: TimeParts, b: TimeParts) -> bool {
	if a.parts != b.parts {
		return a.parts > b.parts
	}
	return a.time < b.time
}

Info :: struct {
	id:    int,
	quest: int,
	part:  int,
	time:  int,
}

// Your answer length is: correct
// The first character of your answer is: incorrect
// 7024075
part3 :: proc() {
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)
	defer vmem.arena_destroy(&arena)

	path := "./04/test"
	data, err := os.read_entire_file(path, arena_alloc)
	if err != nil {
		fmt.println("err reading file")
		return
	}


	infosByQuest := make(map[int][dynamic]Info, arena_alloc)
	pointsById := make(map[int]int, arena_alloc)

	for line in strings.split(string(data), "\n") {
		if line == "" {
			continue
		}
		strs := strings.split(line, " ")
		id := getData(strs[0])
		quest := getData(strs[1])
		part := getData(strs[2])
		time := getData(strs[3])

		values, exist := infosByQuest[quest]
		if !exist {
			values = make([dynamic]Info, arena_alloc)
		}

		append(&values, Info{id, quest, part, time})
		infosByQuest[quest] = values
		pointsById[id] = 0

	}
	// fmt.println("infosByQuest: ", infosByQuest)


	//go over every quest
	for key in infosByQuest {
		//go over every part-> add points to each player id
		infos := infosByQuest[key]
		// infos := infosByQuest[2]
		questTimeById := make(map[int]int, arena_alloc)

		//we go over 3 times first part1,part2,part3
		for partSearched := 1; partSearched <= 3; partSearched += 1 {
			curPartInfo := make([dynamic]Info, arena_alloc)
			for info, i in infos {
				if info.part == partSearched {
					questTime, exist := questTimeById[info.id]
					if !exist {
						questTimeById[info.id] = 0
					}
					existingTime := questTimeById[info.id]
					questTimeById[info.id] = questTimeById[info.id] + info.time


					newInfo := Info {
						id    = info.id,
						quest = info.quest,
						part  = info.part,
						time  = existingTime + info.time,
					}
					append(&curPartInfo, newInfo)
				}
			}
			fmt.println(curPartInfo)
			addPoints(pointsById, curPartInfo[:], partSearched)
			fmt.printfln("quest: %d, part: %d pointsById: %v", key, partSearched, pointsById)
			fmt.println("--")
			// break
		}
		// break
	}
	fmt.println("pointsById: ", pointsById)


	times := make([dynamic]int, arena_alloc)
	for _, value in pointsById {
		append(&times, value)
	}
	slice.sort_by(times[:], reverseSort)
	fmt.println(times)

	PointRank :: struct {
		rank:   int,
		points: int,
	}

	resData := make([dynamic]PointRank, arena_alloc)

	rank := 1
	rankIncrease := 1
	for cur, i in times {

		if i > 0 {
			prev := times[i - 1]
			//we know it must be equal or bigger as it is sorted
			if cur == prev {
				rankIncrease += 1
			} else {
				rank += rankIncrease
				rankIncrease = 1
			}
		}

		append(&resData, PointRank{rank, cur})
	}

	res := 0
	for v in resData {
		res += v.rank * v.points
	}
	fmt.println("res: ", res)
}

addPoints :: proc(pointsById: map[int]int, infos: []Info, part: int) {
	//we sort first
	//than we give points based on part
	slice.sort_by(infos, compPart3)

	points := 0
	//part1=50,part2=100,part3=150 -> all down to 1 point
	if part == 1 {
		points = 50
	} else if part == 2 {
		points = 100
	} else if part == 3 {
		points = 150
	}

	pointsMinus := 1
	for i := 0; i < len(infos); i += 1 {
		cur := infos[i]

		if i > 0 {
			prev := infos[i - 1]
			//we know it must be equal or bigger as it is sorted
			if cur.time == prev.time {
				pointsMinus += 1
			} else {
				points -= pointsMinus
				pointsMinus = 1
			}
		}
		points = math.max(points, 1)

		//I already added all at the beginning this is safe
		value := &pointsById[cur.id]
		value^ = value^ + points


	}
}

compPart3 :: proc(a: Info, b: Info) -> bool {
	return a.time < b.time
}

reverseSort :: proc(a: int, b: int) -> bool {
	return a > b
}
