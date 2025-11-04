extends Area2D
class_name DialogueArea

@export_file("*.json") var Custom_Json
@export var convo = {0:[0, 0]}
@export_multiline var connect_signal:String:
	set(new_value):
		connect_signal = new_value
		var dialogue_signals = Dialogue_System.get_signal_list()
		for S in dialogue_signals:
			if S["name"] in connect_signal and not Dialogue_System.is_connected(S["name"], Callable(self, S["name"])):
				if debug: print(S["name"])
				Dialogue_System.connect(S["name"], Callable(self, S["name"]))
@export var save: bool
@export var remember_convo:bool # only ment to be used when theres no npc body
@export var debug = false
 
# variables
var detect_player:bool = false
var config = ConfigFile.new()
var parent_instance = convo.keys()[0]
var save_name = name
var starting_convo:int
var ending_convo:int


func _ready() -> void:
	collision_layer = 0
	parent_instance = convo.keys()[0]
	
	if get_parent() is NPC:
		save_name = get_parent().name
		for instance in convo: # check every parent_instance
			if not get_parent().saved_instances.has(save_name) or not instance < get_parent().saved_instances[save_name]:
				parent_instance = instance # if the instance has not set it to the main one
				break
		
	
	print(convo[parent_instance][0])
	starting_convo = convo[parent_instance][0]
	ending_convo = convo[parent_instance][1]
	
	if remember_convo:
		if debug: print("remembered convo")
		load_save()
	
	if starting_convo >= 1 and ending_convo <= 0: ending_convo = starting_convo


func _on_body_entered(body: Node2D) -> void: # if the player just entered this body
	if body.has_method("player"): # cheak if the body has the player function
		detect_player = true # turn the player cheach to turn
		collision_layer = 3
		reset_dialogue()
		set_current_dialogue()
		if debug: print("before " + str(starting_convo))
		if debug: print("before " + str(ending_convo))

func _on_body_exited(body: Node2D) -> void: # if the player just exited this body
	if body.has_method("player"): # cheak if the body had the player function
		detect_player = false # turn the player cheack to false
		collision_layer = 0
		update_current_dialogue()
		if save: save_convo()
		if debug: print("after " + str(starting_convo))
		if debug: print("after " + str(ending_convo))


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Continue") and detect_player:
		if Dialogue_System.Deactivated == false:
			if debug: print("talk to " + save_name)
			Dialogue_System.Detect_Player = detect_player
			Dialogue_System.Json_file = Custom_Json
			Dialogue_System.start_dialogue()


func save_convo():
	Dialogue_System.Save_Data["conversations"][save_name] = [starting_convo, ending_convo]
	if get_parent() is NPC:
		Dialogue_System.Save_Data["animations"][save_name] = get_parent().talk_index
	if debug: print("save temp")

func load_save():
	starting_convo = Dialogue_System.Save_Data["conversations"][save_name][0]
	ending_convo =  Dialogue_System.Save_Data["conversations"][save_name][1]


func update_current_dialogue():
	starting_convo = Dialogue_System.Conversation_id # set the current Conversation_id to the Dialogue_System current Conversation_id
	ending_convo = Dialogue_System.Ending_Conversation
	if debug:print(save_name + " saving_dialouge")

func set_current_dialogue():
	if not ending_convo < 0: # the conversation can't end with 0
		Dialogue_System.Ending_Conversation = ending_convo
	if not starting_convo < 1 and not starting_convo > ending_convo:# And set the Dialogue_System.Conversation_id to our Conversation_id
		Dialogue_System.Conversation_id = starting_convo


func reset_dialogue():
	# Reset the value of Dialogue_System current Conversation_id
	Dialogue_System.Conversation_id = Dialogue_System.Default_Conversation_ID
	# Reset the value of Dialogue_System current Ending_Conversation 
	Dialogue_System.Ending_Conversation = Dialogue_System.Default_Ending_Conversation 


func run_signal_actions(action: String): # to run a signal action without runing a signal
	connect_signal = action 
	call(action)


func update_godot_dialogue():
	if debug: print("connected_custom " + save_name)
	if save_name == "Godot Icon" and starting_convo == 6:
		starting_convo = 8
		ending_convo = 9
		save_convo()
	if Dialogue_System.signal_wait_finshed: Dialogue_System.wait_signal_finshed = false
