extends Area2D

class_name Cutscene_trigger

# exports variables
@export var choice:String

@export var run_at_start:bool
 
@export var json_path:String = "res://Resourses/MAIN.json"

@export var cutscene_animation:AnimationPlayer

enum MODES {dialogue, animation}

@export var mode = MODES.dialogue

@export var index:int = 1

@export var conversation:int = 1


# variables
var cutscene_ran = false

var config = ConfigFile.new()

var saved_choices = Dialogue_System.save_data["choices"]

var save_name = ""


# functions
func _ready() -> void:
	if not cutscene_is_available(choice):
		queue_free()
	
	save_name = name + " ran_" + str(index)
	
	if mode == MODES.dialogue: 
		Load_cutscene_state()
		
		if run_at_start and not cutscene_ran:
			run_dialouge()
	
	elif mode == MODES.animation:
		cutscene_animation.play("cutscene " + str(index))


func run_dialouge():
	Dialogue_System.run_dialouge(json_path, conversation)
	
	await Dialogue_System.dialogue_finished
	
	cutscene_ran = true # run once in the same scene, you can change on variable in a save file without editing the rest which is what you can do in this instance with your save system in your own projects
	
	Save_cutscene_state()


func _process(_delta: float) -> void:
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
	
	for choice in saved_choices:
		if instance_choice == choice:
			return true
	
	return false


func Save_cutscene_state():
	Dialogue_System.save_data["cutscene"][save_name] = cutscene_ran


func Load_cutscene_state():
	if not Dialogue_System.save_data["cutscene"].has(save_name):
		return
	
	cutscene_ran = Dialogue_System.save_data["cutscene"][save_name] 
