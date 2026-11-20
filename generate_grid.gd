extends TileMapLayer

@export var grid_width: int = 16
@export var grid_height: int = 16
@export var offset_x: int = 10
@export var offset_y: int = -7

var cells := {}
var highlights: Array[Polygon2D] = []

var unit_scene := preload("res://units.tscn")
var king_data: UnitData = preload("res://Data/Classes/King.tres")
var oracle_data: UnitData = preload("res://Data/Classes/Esoteric_Oracle.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	build_grid()
	spawn_unit(king_data, 1, Vector2i(offset_x + 3, offset_y + 3))
	spawn_unit(oracle_data, 1, Vector2i(offset_x + 4, offset_y +2))
	
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
	add_child(u)
	u.setup(data, player, cell)
	u.position = cell_center(cell)
	cells[cell]["Unit"] = u


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		var cell := local_to_map(get_local_mouse_position())
		clear_highlights()
		if cells.has(cell):
			show_highlight(cell, Color(0.8, 1, 0.1, 0.5))


func show_highlight(cell: Vector2i, color: Color) -> void:
	var h := Polygon2D.new()
	h.polygon = PackedVector2Array([
		Vector2(0, -16), Vector2(32, 0), Vector2(0, 16), Vector2(-32, 0)
	])
	h.color = color
	h.position = map_to_local(cell)
	h.z_index = 1  # draw above tiles and units
	add_child(h)
	highlights.append(h)

func clear_highlights() -> void:
	for h in highlights:
		h.queue_free()
	highlights.clear()
