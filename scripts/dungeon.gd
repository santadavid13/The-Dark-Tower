extends RefCounted
class_name TowerDungeon

enum Tile { FLOOR, WALL, STAIR_UP, STAIR_DOWN }

const SIZE := 11
const LEVEL_COUNT := 22
const TOP_LEVEL := 21

var levels: Array = []


func generate() -> void:
	levels.clear()
	for level_index in LEVEL_COUNT:
		levels.append(_make_level(level_index))


func get_tile(level: int, cell: Vector2i) -> int:
	return levels[level][cell.y][cell.x]


func is_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < SIZE and cell.y < SIZE


func find_tile(level: int, tile: int) -> Vector2i:
	for y in SIZE:
		for x in SIZE:
			if levels[level][y][x] == tile:
				return Vector2i(x, y)
	return Vector2i(-1, -1)


func find_adjacent_floor(level: int, stair: Vector2i) -> Vector2i:
	var dirs: Array[Vector2i] = [
		Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT
	]
	for dir in dirs:
		var next: Vector2i = stair + dir
		if is_inside(next) and get_tile(level, next) == Tile.FLOOR:
			return next

	var queue: Array[Vector2i] = [stair]
	var seen := {stair: true}
	while not queue.is_empty():
		var cell: Vector2i = queue.pop_front()
		for dir in dirs:
			var next: Vector2i = cell + dir
			if not is_inside(next) or seen.has(next):
				continue
			var tile := get_tile(level, next)
			if tile == Tile.WALL:
				continue
			if tile == Tile.FLOOR:
				return next
			seen[next] = true
			queue.append(next)
	return stair


func find_start(level: int) -> Vector2i:
	var stairs := {}
	var up := find_tile(level, Tile.STAIR_UP)
	var down := find_tile(level, Tile.STAIR_DOWN)
	if up.x >= 0:
		stairs[up] = true
	if down.x >= 0:
		stairs[down] = true
	var center := Vector2i(SIZE / 2, SIZE / 2)
	var best := Vector2i(-1, -1)
	var best_dist := 1_000_000
	for y in SIZE:
		for x in SIZE:
			var cell := Vector2i(x, y)
			if levels[level][y][x] != Tile.FLOOR:
				continue
			if stairs.has(cell):
				continue
			var dist: int = absi(cell.x - center.x) + absi(cell.y - center.y)
			if dist < best_dist:
				best_dist = dist
				best = cell
	return best


func _make_level(level_index: int) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20260915 + level_index * 7919

	var grid := _carve_maze(rng)
	var floors: Array[Vector2i] = []
	for y in SIZE:
		for x in SIZE:
			if grid[y][x] == Tile.FLOOR:
				floors.append(Vector2i(x, y))
	for i in range(floors.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap := floors[i]
		floors[i] = floors[j]
		floors[j] = swap

	var stair_count := 0
	if level_index < TOP_LEVEL:
		grid[floors[stair_count].y][floors[stair_count].x] = Tile.STAIR_UP
		stair_count += 1
	if level_index > 0:
		grid[floors[stair_count].y][floors[stair_count].x] = Tile.STAIR_DOWN

	return grid


func _carve_maze(rng: RandomNumberGenerator) -> Array:
	var grid: Array = []
	for y in SIZE:
		var row: Array = []
		row.resize(SIZE)
		row.fill(Tile.WALL)
		grid.append(row)

	var stack: Array[Vector2i] = [Vector2i(0, 0)]
	grid[0][0] = Tile.FLOOR
	var dirs: Array[Vector2i] = [
		Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)
	]

	while not stack.is_empty():
		var current: Vector2i = stack.back()
		var options: Array[Vector2i] = []
		for dir in dirs:
			var next: Vector2i = current + dir * 2
			if is_inside(next) and grid[next.y][next.x] == Tile.WALL:
				options.append(dir)
		if options.is_empty():
			stack.pop_back()
			continue
		var chosen: Vector2i = options[rng.randi_range(0, options.size() - 1)]
		var mid: Vector2i = current + chosen
		var dest: Vector2i = current + chosen * 2
		grid[mid.y][mid.x] = Tile.FLOOR
		grid[dest.y][dest.x] = Tile.FLOOR
		stack.append(dest)

	return grid
