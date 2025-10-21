extends Area2D
class_name DialogueArea

@export_file("*.json") var Custom_Json
@export var starting_conversation = 1
@export var ending_conversation = 0 # has to be an int
@export var connect_signal:String:
	set(new_value):
		connect_signal = new_value
		var dialogue_signals = Dialogue_System.get_signal_list()
		for S in dialogue_signals:
			if S["name"] in connect_signal and not Dialogue_System.is_connected(S["name"], Callable(self, S["name"])):
				print(S["name"])
				Dialogue_System.connect(S["name"], Callable(self, S["name"]))
@export var save: bool
@export var remember_convo:bool # only ment to be used when theres no npc body
@export var debug = false
 
var detect_player:bool = false
var config = ConfigFile.new()
var save_name = name

func _ready() -> void:
	collision_layer = 0
	if not get_parent() == get_tree(): save_name = get_parent().name
	if remember_convo:
		if debug: print("remembered convo")
		load_save()
	if starting_conversation >= 1 and ending_conversation <= 0: ending_conversation = starting_conversation


func _on_body_entered(body: Node2D) -> void: # if the player just entered this body
	if body.has_method("player"): # cheak if the body has the player function
		detect_player = true # turn the player cheach to turn
		collision_layer = 3
		if save: Dialogue_System.Permenently_Save_Data()
		reset_dialogue()
		set_current_dialogue()
		if debug: print("before " + str(starting_conversation))
		if debug: print("before " + str(ending_conversation))

func _on_body_exited(body: Node2D) -> void: # if the player just exited this body
	if body.has_method("player"): # cheak if the body had the player function
		detect_player = false # turn the player cheack to false
		collision_layer = 0
		update_current_dialogue()
		if save: save_convo()
		if debug: print("after " + str(starting_conversation))
		if debug: print("after " + str(ending_conversation))


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Continue") and detect_player:
		if Dialogue_System.Deactivated == false:
			if debug: print("talk to " + save_name)
			Dialogue_System.Detect_Player = detect_player
			Dialogue_System.Json_file = Custom_Json
			Dialogue_System.start_dialogue()


func save_convo():
	print("save temp")
	Dialogue_System.Save_Data["conversations"][save_name] = [starting_conversation, ending_conversation]
	if get_parent() is NPC:
		Dialogue_System.Save_Data["animations"][save_name] = get_parent().talk_index

func load_save():
	starting_conversation = Dialogue_System.Save_Data["conversations"][save_name][0]
	ending_conversation =  Dialogue_System.Save_Data["conversations"][save_name][1]


func update_current_dialogue():
	starting_conversation = Dialogue_System.Conversation_id # set the current Conversation_id to the Dialogue_System current Conversation_id
	ending_conversation = Dialogue_System.Ending_Conversation
	if debug:print(save_name + " saving_dialouge")

func set_current_dialogue():
	if not ending_conversation < 0: # the conversation can't end with 0
		Dialogue_System.Ending_Conversation = ending_conversation
	if not starting_conversation < 1 and not starting_conversation > ending_conversation:
		# And set the Dialogue_System.Conversation_id to our Conversation_id
		Dialogue_System.Conversation_id = starting_conversation


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
	if save_name == "Godot Icon" and starting_conversation == 6:
		starting_conversation = 8
		ending_conversation = 9
		save_convo()
	if Dialogue_System.signal_wait_finshed: Dialogue_System.wait_signal_finshed = false
