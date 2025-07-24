extends Area2D

@export var Run_at_start:bool 
@export var json_path:String = "res://Resourses/MAIN.json"
@export var Index:int = 1
@export var Conversation:int = 1
var Cutscene_ran = false
#constants
const Save_Path = "res://Resourses/save_dialogue.cfg"

# variables
var config = ConfigFile.new()
# Node variables

func Save_cutscene():
	config.set_value("cutscene","cutscene_ran_" + str(Index), Cutscene_ran)
	config.save(Save_Path)

func Load_load():
	var error = config.load(Save_Path) # using the save path to load the save file 
	if error != OK: return
	Cutscene_ran = config.get_value("cutscene","cutscene_ran_" + str(Index), false) # find the value of high score from the save file, if it can't find the high score value set it to the game default: 0 

func _ready() -> void:
	Load_load()
	if Run_at_start:
		Diauloge_Systerm.Run_dialouge(json_path, Conversation)

func _process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.has_method("player") and not Cutscene_ran:
			Diauloge_Systerm.Run_dialouge(json_path, Conversation)
			await Diauloge_Systerm.dialogue_finished
			Cutscene_ran = true # run once in the same scene, you can change on variable in a save file without editing the rest which is what you can do in this instance with your save system in your own projects
			Save_cutscene()
