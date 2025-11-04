extends Node2D
class_name NPC

# @export variables
@export var instances:Dictionary
@export var turn_off_animations: bool # used for nodes you just want to recive dialogue signals 
@export var move_after_talk:bool # use it for a node you want to delete after talking with it and exitsing the scene
@export var remember_temp:bool
@export var dialogue_area:DialogueArea
@export var sprite_animation:AnimationPlayer
@export var talk_index = 0
@export var connect_signal:String: # for every signal in the variable connect to each of them
	set(new_value):
		connect_signal = new_value
		var dialogue_signals = Dialogue_System.get_signal_list()
		for S in dialogue_signals:
			if S["name"] in connect_signal and not Dialogue_System.is_connected(S["name"], Callable(self, S["name"])):
				if debug: print(S["name"])
				Dialogue_System.connect(S["name"], Callable(self, S["name"]))
@export var debug: bool

# variables
var save_data = Dialogue_System.Save_Data
var saved_instances = save_data["npc_instance"]
var saved_convos = save_data["conversations"]

func _ready() -> void:
	if not move_after_talk and not remember_temp: return # if you chose load a save with the npc's name
	
	if not instances.is_empty():
		position = instances[instances.keys()[0]]
		
		if move_after_talk and saved_instances.has(name): # if its set to move and can
			for instance in instances: # check every instance
				var index = instances.keys().find(instance) # in the list of key find the instance and return the name
				print(index)
				if instance < saved_instances[name] and not index + 1 < instances.size(): # if this instance is has passed and there are no more instances: delete 
					if debug: print("delete")
					queue_free()
		
		if move_after_talk:
			for instance in instances: # check every instance
				if not saved_instances.has(name) or not instance < saved_instances[name]: # if they dont have the saved instance or its has not passed 
					var index = instances.keys().find(instance) # in the list of key find the instance and return the name
					saved_instances[name] = instance 
					position = instances[instance]
					if debug: print(saved_instances)
					break # stop checking instances
	
	if remember_temp and saved_convos.has(name) and saved_convos[name][0] >= dialogue_area.starting_convo and saved_convos[name][0] <= dialogue_area.ending_convo:
		# if your not past the ending convo for this instance of this npc then remember the convo 
		dialogue_area.starting_convo = saved_convos[name][0]
		dialogue_area.ending_convo = saved_convos[name][1]
		if debug: print("remembered_temp")


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
