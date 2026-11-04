def part2():
    path = "./07/input"

    with open(path, "r") as f:
        data = f.read()

    energy_by_id = {}
    connections_by_id = {}
    most_connections = {"id": 0, "count": 0}

    for line in data.split("\n"):
        if not line:
            continue

        node = {"id": 0, "energy": 0, "connections": []}

        for s in line.split(", "):
            key, value = s.split("=")

            if key == "id":
                node["id"] = int(value)

            elif key == "energy":
                node["energy"] = int(value)

            elif key == "connections":
                node["connections"] = [int(v) for v in value.split(",")]

        conns = len(node["connections"])
        if conns > most_connections["count"]:
            most_connections["count"] = conns
            most_connections["id"] = node["id"]

        energy_by_id[node["id"]] = node["energy"]
        connections_by_id[node["id"]] = node["connections"]

    print("energy_by_id:", energy_by_id)
    print("connections_by_id:", connections_by_id)
    print("most_connections:", most_connections)

    start_energy = 10

    queue = [(most_connections["id"], start_energy)]

    while queue:
        cur_id, cur_energy = queue.pop(0)

        # Add energy
        energy_by_id[cur_id] += cur_energy

        next_energy = cur_energy - 1
        if next_energy == 0:
            continue

        for connection_id in connections_by_id[cur_id]:
            queue.append((connection_id, next_energy))

    print("energy_by_id:", energy_by_id)

    res = sum(energy_by_id.values())
    print("res:", res)


part2()
