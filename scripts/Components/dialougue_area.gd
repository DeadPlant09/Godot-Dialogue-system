extends Area2D
class_name DialogueArea

@export_file("*.json") var Custom_Json_file_0
@export var starting_conversation = 1
@export var ending_conversation = 0 # has to be an int
@export var connect_signal:String
@export var save_conversation:bool
@export var Debug = false
 
var detect_player:bool = false
var config = ConfigFile.new()

func _ready() -> void:
	collision_layer = 0
	if save_conversation: Load_converstion() 
	if Diauloge_Systerm.has_signal(connect_signal): Diauloge_Systerm.connect(connect_signal, Signal_actions)
	if starting_conversation >= 1 and ending_conversation <= 0: ending_conversation = starting_conversation


func _on_body_entered(body: Node2D) -> void: # if the player just entered this body
	if body.has_method("player"): # cheak if the body has the player function
		detect_player = true # turn the player cheach to turn
		collision_layer = 3
		reset_dialogue()
		set_current_dialogue()
		if Debug: print(ending_conversation)


func _on_body_exited(body: Node2D) -> void: # if the player just exited this body
	if body.has_method("player"): # cheak if the body had the player function
		detect_player = false # turn the player cheack to false
		collision_layer = 0
		update_current_dialogue()
		if save_conversation:
			Save_converstion()
	


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Continue") and detect_player:
		if Diauloge_Systerm.Deactivated == false:
			Diauloge_Systerm.Detect_Player = detect_player
			Diauloge_Systerm.Json_file = Custom_Json_file_0
			Diauloge_Systerm.start_dialogue()
		
	


func Save_converstion():
	if FileAccess.file_exists(Diauloge_Systerm.temp_save_Path): config.load(Diauloge_Systerm.temp_save_Path) 
	config.set_value("conversations", get_parent().name, [starting_conversation, ending_conversation])
	config.save(Diauloge_Systerm.temp_save_Path)


func Load_converstion():
	if config.load(Diauloge_Systerm.temp_save_Path)  != OK: return # using the save path to load the save file 
	starting_conversation = config.get_value("conversations", get_parent().name, [1])[0]
	ending_conversation = config.get_value("conversations", get_parent().name, [1, 0])[1]


func update_current_dialogue():
	starting_conversation = Diauloge_Systerm.conversation_id # set the current conversation_id to the Diauloge_Systerm current conversation_id
	ending_conversation = Diauloge_Systerm.Ending_Conversation
	if Debug:print(get_parent().name + " saving_dialouge")


func set_current_dialogue():
	if not ending_conversation < 0: # the conversation can't end with 0
		Diauloge_Systerm.Ending_Conversation = ending_conversation
	if not starting_conversation < 1 and not starting_conversation > ending_conversation:
		# And set the Diauloge_Systerm.conversation_id to our conversation_id
		Diauloge_Systerm.conversation_id = starting_conversation
	


func reset_dialogue():
	# Reset the value of Diauloge_Systerm current conversation_id
	Diauloge_Systerm.conversation_id = Diauloge_Systerm.Default_Conversation_ID
	# Reset the value of Diauloge_Systerm current Ending_Conversation 
	Diauloge_Systerm.Ending_Conversation = Diauloge_Systerm.Default_Ending_Conversation 


func Signal_actions():
	if Debug: print("connected" + get_parent().name)
	if connect_signal == "update_godot_dialogue":
		if starting_conversation == 6:
			starting_conversation = 8
			ending_conversation = 9
	
