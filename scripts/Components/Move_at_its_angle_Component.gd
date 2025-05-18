extends Node2D
class_name Move_at_its_angle_Component

@export var can_move:bool = true
@export var Moveing_Node:Node2D
@export var Angle_Speed = 1000



func _process(delta: float) -> void:
	Movment(delta)

func Movment(delta):
	var velocity = Vector2.RIGHT.rotated(Moveing_Node.rotation)
	Moveing_Node.position += velocity * 1000 * delta
