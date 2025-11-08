extends Area2D
class_name DialogueArea

@export_file("*.json") var Custom_Json
@export var convo = {0:[0, 0]}
@export var debug = false
 
# variables
var save_data = Dialogue_System.Save_Data
@onready var parent_is_npc = get_parent() is NPC
var detect_player:bool = false
var convo_instance = convo.keys()[0] # default first convo instance (0)
var save_name = name
var starting_convo:int
var ending_convo:int


func _ready() -> void:
	# This is ment for a standalone dialogue area
	collision_layer = 0
	convo_instance = convo.keys()[0] # current first convo instance
	set_convo_to_instance()
	if debug: print("convo_instance " + str(convo_instance))
	
	# This is ment to change for the parent
	if parent_is_npc: # so if the parent is an npc the dialogue area values will get overwriten
		chose_convo()
		save_name = get_parent().name
	
	if debug: print("starting_convo "+ str(convo[convo_instance][0]))


func chose_convo():
	for instance in convo: # check every convo_instance
		if not get_parent().instance_has_passed(instance):
			convo_instance = instance # if the instance has not set it to the main one
			break
	set_convo_to_instance()

func set_convo_to_instance():
	starting_convo = convo[convo_instance][0]
	ending_convo = convo[convo_instance][1]

func set_ending_to_convo():
	if starting_convo >= 1 and ending_convo <= 0:
		ending_convo = starting_convo

func _on_body_entered(body: Node2D) -> void: # if the player just entered this body
	if body.has_method("player"): # cheak if the body has the player function
		detect_player = true # turn the player cheach to turn
		Dialogue_System.current_npc = save_name
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
		if parent_is_npc: save_convo()
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
	save_data["conversations"][save_name] = [starting_convo, ending_convo]
	save_data["animations"][save_name] = get_parent().talk_index
	if debug: print("save temp")


func update_current_dialogue():
	print("update")
	starting_convo = Dialogue_System.Conversation_id # set the current Conversation_id to the Dialogue_System current Conversation_id
	ending_convo = Dialogue_System.Ending_Conversation
	
	if debug:print(save_name + " saving_dialouge")

func set_current_dialogue():
	set_ending_to_convo()
	
	if not ending_convo < 0: # the conversation can't end with 0
		if debug: print("ending "+ str(ending_convo))
		Dialogue_System.Ending_Conversation = ending_convo
		
	if not starting_convo < 1 and not starting_convo > ending_convo:# And set the Dialogue_System.Conversation_id to our Conversation_id
		if debug: print("starting "+ str(starting_convo))
		Dialogue_System.Conversation_id = starting_convo


func reset_dialogue():
	# Reset the value of Dialogue_System current Conversation_id
	Dialogue_System.Conversation_id = Dialogue_System.Default_Conversation_ID
	# Reset the value of Dialogue_System current Ending_Conversation 
	Dialogue_System.Ending_Conversation = Dialogue_System.Default_Ending_Conversation
