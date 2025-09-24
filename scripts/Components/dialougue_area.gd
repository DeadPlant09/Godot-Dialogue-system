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
enum SAVES {empty, Temporary, Permanent}
@export var save_conversation:SAVES = SAVES.empty
@export var Debug = false
 
var detect_player:bool = false
var config = ConfigFile.new()

func _ready() -> void:
	collision_layer = 0
	chose_load()
	if starting_conversation >= 1 and ending_conversation <= 0: ending_conversation = starting_conversation


func _on_body_entered(body: Node2D) -> void: # if the player just entered this body
	if body.has_method("player"): # cheak if the body has the player function
		detect_player = true # turn the player cheach to turn
		collision_layer = 3
		reset_dialogue()
		set_current_dialogue()
		if Debug: print("before " + str(starting_conversation))
		if Debug: print("before " + str(ending_conversation))


func _on_body_exited(body: Node2D) -> void: # if the player just exited this body
	if body.has_method("player"): # cheak if the body had the player function
		detect_player = false # turn the player cheack to false
		collision_layer = 0
		update_current_dialogue()
		chose_save()
		if Debug: print("after " + str(starting_conversation))
		if Debug: print("after " + str(ending_conversation))
	


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Continue") and detect_player:
		if Dialogue_System.Deactivated == false:
			if Debug: print("talk to " + get_parent().name)
			Dialogue_System.Detect_Player = detect_player
			Dialogue_System.Json_file = Custom_Json
			Dialogue_System.start_dialogue()
		
	

func chose_save():
	if save_conversation == SAVES.Temporary: Save_converstion(Dialogue_System.temp_save_Path)
	if save_conversation == SAVES.Permanent: Save_converstion(Dialogue_System.permennt_path)


func chose_load():
	if save_conversation == SAVES.Temporary: Load_converstion(Dialogue_System.temp_save_Path) 
	if save_conversation == SAVES.Permanent: Load_converstion(Dialogue_System.permennt_path)


func Save_converstion(path:String):
	if FileAccess.file_exists(path): config.load(path) 
	config.set_value("conversations", get_parent().name, [starting_conversation, ending_conversation])
	config.save(path)

func Load_converstion(path:String):
	if config.load(path) != OK: return # using the save path to load the save file 
	starting_conversation = config.get_value("conversations", get_parent().name, [1])[0]
	ending_conversation = config.get_value("conversations", get_parent().name, [1, 0])[1]


func update_current_dialogue():
	starting_conversation = Dialogue_System.Conversation_id # set the current Conversation_id to the Dialogue_System current Conversation_id
	ending_conversation = Dialogue_System.Ending_Conversation
	if Debug:print(get_parent().name + " saving_dialouge")

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
	if Debug: print("connected_custom " + get_parent().name)
	if get_parent().name == "Godot Icon" and starting_conversation == 6:
		starting_conversation = 8
		ending_conversation = 9
		chose_save()
	if Dialogue_System.signal_wait_finshed: Dialogue_System.wait_signal_finshed = false
