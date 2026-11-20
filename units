class_name Unit
extends Node2D

var data: UnitData
var player: int #Which player does the unit belong to
var unit_coordinate: Vector2i #(col, row)
var is_alive: bool = true
var curr_hp: int = 10

func setup(p_data: UnitData, p_player: int, p_cell: Vector2i) -> void:
	data = p_data
	player = p_player
	unit_coordinate = p_cell
	curr_hp = data.max_hp
	if data.texture:
		$Sprite2D.texture = data.texture
