extends Area2D

@export var Run_at_start:bool 
@export var json_path:String = "res://Resourses/MAIN.json"
@export var Conversation:int = 1


func _ready() -> void:
	if Run_at_start:
		Diauloge_Systerm.Run_dialouge(json_path, Conversation)

func _process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.has_method("player"):
			Diauloge_Systerm.Run_dialouge(json_path, Conversation)
			collision_mask = 0
