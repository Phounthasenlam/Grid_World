extends TileMapLayer

@export var grid_width: int = 16
@export var grid_height: int = 16
@export var offset_x: int = 10
@export var offset_y: int = -7

@onready var units_node: Node2D = $Units
@onready var highlights_node: Node2D = $Highlights

var cells := {}
var highlights: Array[Polygon2D] = []
var selected_unit: Unit = null 

var unit_scene := preload("res://units.tscn")
var king_data: UnitData = preload("res://Data/Classes/King.tres")
var oracle_data: UnitData = preload("res://Data/Classes/Esoteric_Oracle.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	build_grid()
	spawn_unit(king_data, 1, Vector2i(offset_x + 3, offset_y + 3))
	spawn_unit(oracle_data, 1, Vector2i(offset_x + 4, offset_y +2))
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		var cell := local_to_map(get_local_mouse_position())
		if not cells.has(cell):
			deselect()
			return
		
		var clicked_unit = cells[cell]["Unit"]

		if clicked_unit != null:
			if clicked_unit == selected_unit: #the same unit
				deselect()
			else:
				select_unit(clicked_unit)
		elif selected_unit != null and get_valid_movement_cells(selected_unit).has(cell):
			move_unit(selected_unit, cell);
			deselect()
		else:
			deselect()

	
#We might need to save cells into an array, but thats another day/plan.
func build_grid() -> void:
	for row in range(grid_height):
		for col in range(grid_width):
			var cell := Vector2i(offset_x + col ,offset_y + row)
			set_cell(cell, 0, Vector2i(0,0))
			cells[cell] = {"Unit" : null}
			
			
func cell_center(cell: Vector2i) -> Vector2:
	return map_to_local(cell) 


func spawn_unit(data: UnitData, player: int, cell: Vector2i) -> void:
	var u: Unit = unit_scene.instantiate()
	units_node.add_child(u)
	u.setup(data, player, cell)
	u.position = cell_center(cell)
	cells[cell]["Unit"] = u
		
		
func get_cells_in_pattern(start: Vector2i, pattern: Array[Vector2i]) -> Array[Vector2i]:
	var valid_cells: Array[Vector2i] = []
	for offset in pattern:
		var target_cell := start + offset
		if cells.has(target_cell):
			valid_cells.append(target_cell)
	return valid_cells

# shared: pattern cells on the board, minus blocked paths
func get_unblocked_cells(start: Vector2i, pattern: Array[Vector2i], ignore_blocking := false) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for c in get_cells_in_pattern(start, pattern):
		if ignore_blocking or not is_path_blocked(start, c):
			result.append(c)
	return result

# movement rule: destination must be empty
func get_valid_movement_cells(unit: Unit) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for c in get_unblocked_cells(unit.coordinates, unit.data.move_pattern, unit.data.can_leap):
		if cells[c]["Unit"] == null:
			result.append(c)
	return result

# attack rule: skip your own units (empty cells and enemies are fine)
func get_valid_attack_cells(unit: Unit, ability: Ability) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for c in get_unblocked_cells(unit.coordinates, ability.pattern, ability.can_cleave):
		var other = cells[c]["Unit"]
		if other == null or other.player != unit.player:
			result.append(c)
	return result
	
	
func _step(offset: int, i: int, steps: int) -> int:
	return signi(offset) * ((2 * absi(offset) * i + steps) / (2*steps))


func get_line_between(start: Vector2i, target: Vector2i) -> Array[Vector2i]:
	var d_cell := target - start
	var steps := maxi(absi(d_cell.x), absi(d_cell.y))
	var tiles: Array[Vector2i] = []
	
	for i in range(1, steps):
		tiles.append(Vector2i(
			start.x + _step(d_cell.x, i, steps), 
			start.y + _step(d_cell.y, i, steps)
		))
	
	return tiles


func is_path_blocked(start: Vector2i, target: Vector2i) -> bool:
	var path := get_line_between(start, target);
	return path.any(func(c): return cells[c]["Unit"] != null)
	

func select_unit(unit: Unit) -> void:
	clear_highlights()
	selected_unit = unit #Cache the unit
	for cell in get_valid_movement_cells(unit):
		show_highlight(cell, Color(0.8, 1, 0.1, 0.5))
	show_highlight(unit.coordinates, Color(0.8, 1, 0.1, 0.5))
		
		
func deselect() -> void:
	selected_unit = null
	clear_highlights()
	

func move_unit(unit: Unit, target: Vector2i) -> void:
	cells[unit.coordinates]["Unit"] = null
	cells[target]["Unit"] = unit
	unit.coordinates = target
	unit.position = cell_center(target)


func show_highlight(cell: Vector2i, color: Color) -> void:
	var h := Polygon2D.new()
	h.polygon = PackedVector2Array([
		Vector2(0, -16), Vector2(32, 0), Vector2(0, 16), Vector2(-32, 0)
	])
	h.color = color
	h.position = map_to_local(cell)
	highlights_node.add_child(h)
	highlights.append(h)


func clear_highlights() -> void:
	for h in highlights:
		h.queue_free()
	highlights.clear()


"""
TODO:
	-implement Attack tiles
"""
