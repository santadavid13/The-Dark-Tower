extends Node2D

const CELL := 52
const GAP := 3
const GRID_PIXELS := TowerDungeon.SIZE * CELL

var dungeon := TowerDungeon.new()
var level := 0
var player := Vector2i.ZERO
var skip_stairs_at := Vector2i(-1, -1)
var skip_stairs_level := -1

@onready var status_label: Label = $HUD/Status


func _ready() -> void:
	dungeon.generate()
	player = dungeon.find_start(0)
	_refresh_hud()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	var step := Vector2i.ZERO
	if event.is_action("move_left"):
		step = Vector2i.LEFT
	elif event.is_action("move_right"):
		step = Vector2i.RIGHT
	elif event.is_action("move_up"):
		step = Vector2i.UP
	elif event.is_action("move_down"):
		step = Vector2i.DOWN
	if step == Vector2i.ZERO:
		return
	_try_step(step)
	get_viewport().set_input_as_handled()


func _try_step(step: Vector2i) -> void:
	var destination := player + step
	if not dungeon.is_inside(destination):
		return
	if dungeon.get_tile(level, destination) == TowerDungeon.Tile.WALL:
		return
	player = destination
	_resolve_stairs()
	_refresh_hud()
	queue_redraw()


func _resolve_stairs() -> void:
	if skip_stairs_level == level and skip_stairs_at == player:
		return

	var tile := dungeon.get_tile(level, player)
	if tile == TowerDungeon.Tile.STAIR_UP and level < TowerDungeon.TOP_LEVEL:
		_arrive_on_level(level + 1, TowerDungeon.Tile.STAIR_DOWN)
	elif tile == TowerDungeon.Tile.STAIR_DOWN and level > 0:
		_arrive_on_level(level - 1, TowerDungeon.Tile.STAIR_UP)


func _arrive_on_level(next_level: int, arrival_stair: int) -> void:
	level = next_level
	var stair := dungeon.find_tile(level, arrival_stair)
	player = dungeon.find_adjacent_floor(level, stair)
	var landed := dungeon.get_tile(level, player)
	if landed == TowerDungeon.Tile.STAIR_UP or landed == TowerDungeon.Tile.STAIR_DOWN:
		skip_stairs_level = level
		skip_stairs_at = player
	else:
		skip_stairs_level = -1
		skip_stairs_at = Vector2i(-1, -1)


func _refresh_hud() -> void:
	var tile := dungeon.get_tile(level, player)
	var on := ""
	if tile == TowerDungeon.Tile.STAIR_UP:
		on = "  ·  on stairs up"
	elif tile == TowerDungeon.Tile.STAIR_DOWN:
		on = "  ·  on stairs down"
	status_label.text = "Level %d / %d%s\nWASD or arrows: one tile. Gold U = up. Blue D = down. You appear beside the stair." % [
		level, TowerDungeon.TOP_LEVEL, on
	]


func _draw() -> void:
	var origin := Vector2((1280 - GRID_PIXELS) * 0.5, (720 - GRID_PIXELS) * 0.5 + 16)
	draw_rect(Rect2(origin - Vector2(8, 8), Vector2(GRID_PIXELS + 16, GRID_PIXELS + 16)), Color(0.08, 0.07, 0.11))
	for y in TowerDungeon.SIZE:
		for x in TowerDungeon.SIZE:
			var cell := Vector2i(x, y)
			var rect := Rect2(
				origin + Vector2(x * CELL + GAP, y * CELL + GAP),
				Vector2(CELL - GAP * 2, CELL - GAP * 2)
			)
			var tile := dungeon.get_tile(level, cell)
			draw_rect(rect, _tile_color(tile))
			if tile == TowerDungeon.Tile.STAIR_UP or tile == TowerDungeon.Tile.STAIR_DOWN:
				var mark := "U" if tile == TowerDungeon.Tile.STAIR_UP else "D"
				draw_string(
					ThemeDB.fallback_font,
					rect.position + Vector2(12, 32),
					mark,
					HORIZONTAL_ALIGNMENT_LEFT,
					-1,
					22,
					Color(0.08, 0.07, 0.11)
				)
	var player_rect := Rect2(
		origin + Vector2(player.x * CELL + 12, player.y * CELL + 12),
		Vector2(CELL - 24, CELL - 24)
	)
	draw_rect(player_rect, Color(0.86, 0.58, 0.28))


func _tile_color(tile: int) -> Color:
	match tile:
		TowerDungeon.Tile.WALL:
			return Color(0.16, 0.13, 0.2)
		TowerDungeon.Tile.STAIR_UP:
			return Color(0.78, 0.62, 0.22)
		TowerDungeon.Tile.STAIR_DOWN:
			return Color(0.28, 0.42, 0.62)
		_:
			return Color(0.32, 0.28, 0.36)
