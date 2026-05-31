extends Area2D

class_name DialogueArea

# export variables
@export_file("*.json") var custom_json

@export var convo = {0:[0, 0]}
 
# variables
@onready var parent_is_npc = get_parent() is NPC

var save_data = Dialogue_System.save_data

var detect_player:bool = false

# default first convo instance (0)
var convo_instance = convo.keys()[0]

var save_name = name

var starting_convo:int

var ending_convo:int


func _ready() -> void:
	set_default_instance_to_default_convo()


func set_default_instance_to_default_convo():
	# This is ment for a standalone dialogue area
	collision_layer = 0
	
	# current first convo instance
	convo_instance = convo.keys()[0] 
	
	set_instance_to_current_convo()
	
	# This is ment to change for the parent
	# so if the parent is an npc the dialogue area values will get overwriten
	if parent_is_npc:
		chose_current_npc_instance()
		
		save_name = get_parent().name


func _input(event: InputEvent) -> void:
	if not Dialogue_System.deactivated == false or not detect_player:
		return
	
	if event.is_action_pressed("Continue"):
		Dialogue_System.detect_player = detect_player
		Dialogue_System.json_file = custom_json
		
		Dialogue_System.start_dialogue() 


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("player"): 
		# turn the player check to true
		detect_player = true
		Dialogue_System.current_npc = save_name
		collision_layer = 3
		
		reset_dialogue()
		set_current_dialogue()


func _on_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		# turn the player check to false
		detect_player = false
		collision_layer = 0
		
		update_current_dialogue()
		
		if parent_is_npc:
			save_convo()


func chose_current_npc_instance():
	# check every convo_instance
	for instance in convo:
		if not get_parent().instance_has_passed(instance):
			# if the instance has not set it to the main one
			convo_instance = instance
			
			break
	
	set_instance_to_current_convo()


func set_instance_to_current_convo():
	starting_convo = convo[convo_instance][0]
	ending_convo = convo[convo_instance][1]


func set_ending_to_convo():
	if starting_convo >= 1 and ending_convo <= 0:
		ending_convo = starting_convo


func save_convo():
	save_data["conversations"][save_name] = [starting_convo, ending_convo]


func update_current_dialogue():
	# set the current conversation_id to the Dialogue_System current conversation_id
	starting_convo = Dialogue_System.conversation_id 
	ending_convo = Dialogue_System.ending_conversation_id


func set_current_dialogue():
	set_ending_to_convo()
	
	# the conversation can't end with 0
	if not ending_convo < 0:
		Dialogue_System.ending_conversation_id = ending_convo
	
	# set the Dialogue_System.conversation_id to our conversation_id
	if not starting_convo < 1 and not starting_convo > ending_convo:
		Dialogue_System.conversation_id = starting_convo


func reset_dialogue():
	# Reset the value of Dialogue_System current conversation_id
	Dialogue_System.conversation_id = Dialogue_System.default_conversation_id
	
	# Reset the value of Dialogue_System current ending_conversation_id 
	Dialogue_System.ending_conversation_id = Dialogue_System.default_ending_conversation_id
