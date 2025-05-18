extends Node
class_name Move_Component

@export var Can_move:bool = true
@export var velocity: Vector2
@export var Aceleration = 10
@export var Moveing_Node:Node2D


func _process(delta: float) -> void:
	movevment(delta)
	

func movevment(delta):
	if Can_move == true:
		Moveing_Node.translate((velocity * Aceleration) * delta)
