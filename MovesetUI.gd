class_name MovesetMenu
extends Control

signal ability_selected(ability: Ability)

@onready var panel: PanelContainer = $UI/Panel
@onready var row: HBoxContainer = $UI/Panel/MarginContainer/HBoxContainer

func _ready() -> void:
	var m := $UI/Panel/MarginContainer
	for side in ["margin_top", "margin_bottom", "margin_left", "margin_right"]:
		m.add_theme_constant_override(side, 16)
	panel.hide()

func show_for(unit: Unit) -> void:
	for child in row.get_children():
		row.remove_child(child)
		child.queue_free()
	for ability in unit.data.abilities:
		var btn := Button.new()
		btn.text = ability.ability_name
		btn.custom_minimum_size = Vector2(100, 100)
		btn.pressed.connect(_on_move_pressed.bind(ability))
		row.add_child(btn)
	panel.show()

func hide_menu() -> void:
	panel.hide()

func _on_move_pressed(ability: Ability) -> void:
	ability_selected.emit(ability)
