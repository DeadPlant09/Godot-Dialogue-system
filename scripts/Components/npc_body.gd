extends CharacterBody2D

# @export variables
@export var JUST_RECIVE_SIGNALS:bool
@export var Move_NPC_after_talk:bool
@export var dialogue_area:DialogueArea
@export var Sprite_animation:AnimationPlayer
@export var connect_signal:String:
	set(new_value):
		connect_signal = new_value
		if not Dialogue_System.is_connected(connect_signal, Signal_actions):
			Dialogue_System.connect(connect_signal, Signal_actions)# so the signal constantly updates

# variables
var is_talking:bool
var player_in_diulogue_area
var talk_index = 0

func _ready() -> void: # remember to transfer save data ovrt to a personal one
	var config = ConfigFile.new()
	if not Move_NPC_after_talk or config.load(Dialogue_System.temp_save_Path) != OK: return # if you can load a save with the npc's name
	if config.get_value("conversations", name)[0] >= dialogue_area.starting_conversation: # and the saves starting conve index is lest than or equal to the current convo index
		queue_free()  


func _process(_delta: float) -> void:
	if JUST_RECIVE_SIGNALS: return
	
	if dialogue_area.detect_player and name in Dialogue_System.Sprites.get_child(2).text:  # if the player is in the area and the npc is speaking 
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
	if Dialogue_System.signal_wait_finshed: Dialogue_System.wait_signal_finshed = false
