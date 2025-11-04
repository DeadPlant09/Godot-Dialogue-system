extends Area2D
class_name Cutscene_trigger

# exports variables
@export var Run_at_start:bool 
@export var json_path:String = "res://Resourses/MAIN.json"
@export var Cutscene_Animation:AnimationPlayer
enum MODES {dialogue, animation}
@export var Mode = MODES.dialogue
@export var Index:int = 1
@export var Conversation:int = 1
@export var debug = false


# variables
var Cutscene_ran = false
var config = ConfigFile.new()


# functions
func _ready() -> void:
	if Mode == MODES.dialogue: 
		Load_cutscene_state()
		if Run_at_start and not Cutscene_ran: run_dialouge()
	elif Mode == MODES.animation:
		Cutscene_Animation.play("cutscene " + str(Index))

func run_dialouge():
	Dialogue_System.Run_dialouge(json_path, Conversation)
	await Dialogue_System.dialogue_finished
	if debug: (name + " ran_" + str(Index))
	Cutscene_ran = true # run once in the same scene, you can change on variable in a save file without editing the rest which is what you can do in this instance with your save system in your own projects
	Save_cutscene_state()


func _process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.has_method("player") and not Cutscene_ran:
			if Mode == MODES.dialogue: run_dialouge()
			if Mode == MODES.animation:
				Dialogue_System.remove_player_input()
				Cutscene_Animation.play("cutscene")
				await Cutscene_Animation.animation_finished
				Cutscene_ran = true
				Dialogue_System.add_player_input()


func Save_cutscene_state():
	Dialogue_System.Save_Data["cutscene"][ name + " ran_" + str(Index)] = Cutscene_ran
	if debug: print( name + " ran_" + str(Index) + " saved")

func Load_cutscene_state():
	if not Dialogue_System.Save_Data["cutscene"].has( name + " ran_" + str(Index)): return
	Cutscene_ran = Dialogue_System.Save_Data["cutscene"][ name + " ran_" + str(Index)] # find the value of high score from the save file, if it can't find the high score value set it to the game default: 0 
	if debug: print( name + " ran_" + str(Index) + " loaded")
