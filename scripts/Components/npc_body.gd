extends Node2D
class_name NPC

# @export variables
@export var turn_off_animations: bool # used for nodes you just want to recive dialogue signals 
@export var move_npc_after_talk:bool # use it for a node you want to delete after talking with it and exitsing the scene
@export var remember_temp:bool
@export var dialogue_area:DialogueArea
@export var sprite_animation:AnimationPlayer
@export var connect_signal:String: # change to "connect_to_signals"
	set(new_value):
		connect_signal = new_value
		var dialogue_signals = Dialogue_System.get_signal_list()
		for S in dialogue_signals:
			if S["name"] in connect_signal and not Dialogue_System.is_connected(S["name"], Callable(self, S["name"])):
				if debug: print(S["name"])
				Dialogue_System.connect(S["name"], Callable(self, S["name"]))
@export var debug: bool

# variables
var is_talking:bool
var player_in_diulogue_area
var talk_index = 0

func _ready() -> void: # remember to transfer save data over to a global one
	print("ready")
	var config = ConfigFile.new()
	
	if not move_npc_after_talk and not remember_temp: return # if you can load a save with the npc's name
	if config.load(Dialogue_System.permennt_path) != OK and Dialogue_System.Save_Data["conversations"].has(name): return
	
	if move_npc_after_talk and config.get_value("conversations", name)[0] >= dialogue_area.starting_conversation: # and the saves starting conve index is lest than or equal to the current convo index
		if debug: print("delete")
		queue_free()
	
	elif remember_temp and Dialogue_System.Save_Data["conversations"].has(name):
		print("remember_temp")
		dialogue_area.starting_conversation = Dialogue_System.Save_Data["conversations"][name][0]


func _process(_delta: float) -> void: if sprite_animation != null: npc_animations()


func npc_animations():
	if turn_off_animations: return
	
	if dialogue_area.detect_player and name in Dialogue_System.Sprites.get_child(2).text: # if the npc is talking
		if Dialogue_System.Is_Dialogue_Runing: # if the npc is currently talking
			sprite_animation.play("Talk" + str(talk_index))
		else: # if the npc is finsished talking
			sprite_animation.pause()
			sprite_animation.play("Talk" + str(talk_index))
	
	else: # if the npc isnt talking
		sprite_animation.get_animation(sprite_animation.name + str(talk_index)).loop_mode = Animation.LOOP_LINEAR
		sprite_animation.play(sprite_animation.name + str(talk_index))


func run_signal_actions(action: String): # to run a signal action without runing a signal
	connect_signal = action 
	call(action)


func Signal_actions():
	if connect_signal == "update_godot_dialogue":
		print("connect")
	if Dialogue_System.signal_wait_finshed: Dialogue_System.wait_signal_finshed = false
