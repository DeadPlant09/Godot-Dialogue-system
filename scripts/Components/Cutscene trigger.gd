extends Area2D
class_name Cutscene_trigger

# variables
@export var Run_at_start:bool 
@export var json_path:String = "res://Resourses/MAIN.json"
@export var Cutscene_Animation:AnimationPlayer
enum MODES {dialogue, animation}
@export var Mode = MODES.dialogue
@export var Index:int = 1
@export var Conversation:int = 1
@export var Debug = false
var Cutscene_ran = false
var config = ConfigFile.new()
var save_name = name + " ran_" + str(Index)

# functions
func Save_cutscene():
	if FileAccess.file_exists(Dialogue_System.temp_save_Path): config.load(Dialogue_System.temp_save_Path) 
	config.set_value("cutscene", save_name, Cutscene_ran)
	config.save(Dialogue_System.temp_save_Path)
	if Debug: print( name + " saved")

func Load_load():
	var error = config.load(Dialogue_System.temp_save_Path) # using the save path to load the save file 
	if error != OK: return
	Cutscene_ran = config.get_value("cutscene", save_name, false) # find the value of high score from the save file, if it can't find the high score value set it to the game default: 0 
	if Debug: print(name + " loaded")

func _ready() -> void:
	if Mode == MODES.dialogue: 
		Load_load()
		if Run_at_start and not Cutscene_ran: run_dialouge()
	elif Mode == MODES.animation:
		Cutscene_Animation.play("cutscene " + str(Index))

func run_dialouge():
	Dialogue_System.Run_dialouge(json_path, Conversation)
	await Dialogue_System.dialogue_finished
	if Debug: print(name + " ran")
	Cutscene_ran = true # run once in the same scene, you can change on variable in a save file without editing the rest which is what you can do in this instance with your save system in your own projects
	Save_cutscene()

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
