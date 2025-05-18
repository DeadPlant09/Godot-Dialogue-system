extends Node

@export var Rotating_Object:Node2D
@export var rotation_speed:int = 20

func _ready() -> void:
	Rotate()
	

func Rotate():
	Rotating_Object.rotate(rotation_speed)
	
	

