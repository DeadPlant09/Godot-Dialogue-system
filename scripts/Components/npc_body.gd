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
	if Diauloge_Systerm.has_signal(connect_signal): Diauloge_Systerm.connect(connect_signal, Signal_actions)


func _process(_delta: float) -> void:
	if dialogue_area.detect_player and Diauloge_Systerm.Sprites.get_child(2).text == name:  # if the player is in the area and the npc is speaking 
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
		if not Diauloge_Systerm.Is_Dialogue_Runing: # if the npc is not currently talking
			Sprite_animation.pause()
			Sprite_animation.play("Talk" + str(talk_index))


func run_signal_actions(action: String): # to run a signal action without runing a signal
	connect_signal = action 
	Signal_actions()


func Signal_actions():
	if connect_signal == "update_godot_dialogue":
		print("connect")
	if Diauloge_Systerm.signal_wait_finshed: Diauloge_Systerm.wait_signal_finshed = false
