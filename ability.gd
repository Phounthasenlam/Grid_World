class_name Ability 
extends Resource

@export var ability_name: String
@export var pattern: Array[Vector2i] = [] #(col, row)
@export var effect: String #What is the effect of the ability: damage, buffing, etc
@export var effect_amount: int
@export var cost: int #Cost of using the ability
@export var target: String #Who are the targets of the ability: enemy, ally, self, etc
