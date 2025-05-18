@icon("res://Sprites/Objects/Npc icon.png") # the icon for the node in the editor
class_name NPC_Body
extends CharacterBody2D

# @export variables
@export var dialogue_area:DialogueArea
@export var Sprite_animation:AnimationPlayer

# variables
var is_moving:bool
var player_in_diulogue_area
var play_talking_animation = true
@export var start_from_positon:Vector2
@export var go_to_positon:Vector2

func _process(_delta: float) -> void:
	#Back_and_fouth()
	if dialogue_area.detect_player and Input.is_action_just_pressed("Continue"):
		is_moving = false
	if Diauloge_Systerm.Deactivated == false: # if the Diauloge_Systerm is done with dialogue 
		is_moving = true
	if Sprite_animation != null:
		npc_animations()
	

#func Back_and_fouth():
	#if position != go_to_positon and is_moving:
		#position += go_to_positon
	#elif position != start_from_positon and is_moving:
		#position += start_from_positon

func npc_animations():
	if is_moving: 
		Sprite_animation.get_animation(Sprite_animation.name).loop_mode = Animation.LOOP_LINEAR
		Sprite_animation.play(Sprite_animation.name)
	else:
		if play_talking_animation:
			Sprite_animation.play("Talk")
			if Diauloge_Systerm.is_dialogue_runing:
				Sprite_animation.play("Talk")
			elif Diauloge_Systerm.has_dialogue_ran:
				Sprite_animation.pause()
				Sprite_animation.play("Talk")
			
