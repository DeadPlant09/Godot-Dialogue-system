extends Area2D


@export var Scene:String

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		get_tree().call_deferred("change_scene_to_packed", load(Scene))# "call_deferred" run's the function at the end of the signal as to not cause errors when emedeitly removing a colision object from an area. 
		
	
