class_name UnitData
extends Resource

@export var unit_name: String
@export var texture: Texture2D

#maybe add more stats such as move_resist or passive_abilities 
@export_group("Stats")
@export var max_hp: int = 10
@export var defense: int = 5
@export var attack: int = 5
@export var speed: int = 5 #determines how expensive it is for the char to move, the faster the cheaperu  
@export var evasion: int = 5
@export var accuracy: int = 5

@export_group("Movement")
@export var move_pattern: Array[Vector2i] = []
@export var can_leap: bool = false
@export var is_odd_movement_pattern: bool = false

@export_group("Abilities")
@export var abilities: Array[Ability] = []
