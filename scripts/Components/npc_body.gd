extends CharacterBody2D

# @export variables
@export var dialogue_area:DialogueArea
@export var Sprite_animation:AnimationPlayer
@export var connect_signal:String

# variables
var is_talking:bool
var player_in_diulogue_area
var talk_index = 0

func _ready() -> void: 
	if Dialogue_System.has_signal(connect_signal): Dialogue_System.connect(connect_signal, Signal_actions)


func _process(_delta: float) -> void:
	if dialogue_area.detect_player and Dialogue_System.Sprites.get_child(2).text == name:  # if the player is in the area and the npc is speaking 
		is_talking = true
	else: # if the player isnt in the area or the npc isnt speaking 
		is_talking = false 
	if Sprite_animation != null: npc_animations()
	


func npc_animations():
	if not is_talking: # if the npc isnt talking
		Sprite_animation.get_animation(Sprite_animation.name + str(talk_index)).loop_mode = Animation.LOOP_LINEAR
		Sprite_animation.play(Sprite_animation.name + str(talk_index))
	else: # if the npc is talking
		Sprite_animation.play("Talk" + str(talk_index))
		if Dialogue_System.is_dialogue_runing: # if the npc is currently talking
			Sprite_animation.play("Talk" + str(talk_index))
		else: # if the npc is finsished talking
			Sprite_animation.pause()
			Sprite_animation.play("Talk" + str(talk_index))


func run_signal_actions(action: String): # to run a signal action without runing a signal
	connect_signal = action 
	Signal_actions()


func Signal_actions():
	if connect_signal == "update_godot_dialogue":
		print("connect")
	
