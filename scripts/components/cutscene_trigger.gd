extends Area2D

class_name Cutscene_trigger

# exports variables
@export var choice:String

@export var run_at_start:bool
 
@export_file("*.json") var json_path = "res://resourses/main.json"

@export var cutscene_animation:AnimationPlayer

enum MODES {dialogue, animation}

@export var mode = MODES.dialogue

@export var conversation:int = 1


# variables
var cutscene_ran = false

var saved_choices = Dialogue_System.save_data["choices"]

var save_name = ""


# functions
func _ready() -> void:
	if not cutscene_is_available(choice):
		queue_free()
	
	save_name = name + " ran" 
	
	if mode == MODES.dialogue: 
		Load_cutscene_state()
		
		if run_at_start and not cutscene_ran:
			run_dialouge()
	
	elif mode == MODES.animation:
		cutscene_animation.play("cutscene")


func run_dialouge():
	Dialogue_System.run_dialouge(json_path, conversation)
	
	await Dialogue_System.dialogue_finished
	
	cutscene_ran = true
	
	Save_cutscene_state()


func _process(_delta: float) -> void:
	if Dialogue_System.deactivated:
		return
	
	for body in get_overlapping_bodies():
		if body.has_method("player") and not cutscene_ran:
			if mode == MODES.dialogue:
				run_dialouge()
			
			elif mode == MODES.animation:
				Dialogue_System.remove_player_input()
				cutscene_animation.play("cutscene")
				
				await cutscene_animation.animation_finished
				
				cutscene_ran = true
				
				Dialogue_System.add_player_input()


func cutscene_is_available(instance_choice: String):
	if instance_choice == "":
		return true
	
	for past_choice in saved_choices:
		if instance_choice == past_choice:
			return true
	
	return false


func Save_cutscene_state():
	Dialogue_System.save_data["cutscene"][save_name] = cutscene_ran
	
	# for testing remove in your own project
	Dialogue_System.permenently_save_data()


func Load_cutscene_state():
	if not Dialogue_System.save_data["cutscene"].has(save_name):
		return
	
	cutscene_ran = Dialogue_System.save_data["cutscene"][save_name] 
