extends CanvasLayer

class_name DialogueSystem

# signal
signal dialogue_finished

signal signal_wait_finished

signal choice_was_made

# custom signals
signal sure_the_earth_is_flat

signal your_crazy

signal leave_scene_right

signal leave_scene_left

# node variables
@onready var dialogue_ui:Control = $"Dialogue UI"

@onready var sprites:Control = $"Dialogue UI/Sprites"

@onready var character_text:RichTextLabel = $"Dialogue UI/Character Text"

@onready var character_voice:AudioStreamPlayer2D = $"Dialogue UI/Voice"

@onready var options:Control = $"Dialogue UI/Options"

@onready var reactions:Array = [$"Dialogue UI/Reaction 1", $"Dialogue UI/Reaction 2", $"Dialogue UI/Reaction 3", $"Dialogue UI/Reaction 4"]

@onready var profile_animation:AnimationPlayer = $"Dialogue UI/Profile animations"

@onready var show_responce:AnimationPlayer = $"Dialogue UI/Show Responce"

@onready var dialogue_ui_2:Control = $"Dialogue UI 2"

@onready var sprites_2:Control = $"Dialogue UI 2/Sprites"

@onready var character_text_two:RichTextLabel = $"Dialogue UI 2/Character Text"

@onready var character_voice_2:AudioStreamPlayer2D = $"Dialogue UI 2/Voice"

@onready var profile_animation_2:AnimationPlayer = $"Dialogue UI 2/Profile animations"

# dictionary
var save_data:Dictionary = {
	"cutscene":{}, 
	"conversations":{}, 
	"npc_instance":{}, 
	"choices":{}
	}

# constants
const PERMENENT_PATH = "res://save_conv_per.cfg" 

# variables
# nesasary variables
@export_file("*.json") var json_file

@export var profile_path = "res://aprites/characters/"

@export_file("*.wav") var voice_path = "res://audio/"

var detect_player:bool = false

var name_box: NinePatchRect

var character_name: RichTextLabel

var character_icon: Sprite2D

var name_box_two: NinePatchRect

var character_name_two: RichTextLabel

var character_icon_two: Sprite2D

var json_dialogue:Variant = []

var default_conversation_id:int = 1

var default_ending_conversation_id:int = 0

var default_dialogue_id:int = 0

var conversation_id:int = default_conversation_id

var ending_conversation_id:int = default_ending_conversation_id

var current_diauogue_id:int = default_dialogue_id

var deactivated:bool = false

var is_dialogue_runing:bool = false

var choices_exsist:bool = false

var current_dialogue:Variant

var current_npc:Variant

var choice_responses:Variant

var choice_aftermath:Variant

# optional variables
var in_cutscene:bool = false

var can_move:bool = false

var emit_custom:Variant = [false]:
	set(new_value):
		emit_custom = new_value
		
		# emit_signal_after_dialogue = false
		if emit_custom.size() == 2 and emit_custom[0] == false:
			emit_signal(emit_custom[1])

var default_volume_db:float = 0.0

var skipable:bool = true

var play_voice:bool = true

var auto_skip:bool = false

var wait_for_responses:bool = false

var pause_at_character = [",", "-", ";", ":", ".", "?", "!"]

var pause_at_ending_of_sentence:bool = true

var silent_characters = [" ","!",",", "-", ".", "?",";", '"', "©", "™", "[", "]"]

var just_show_text:bool = false

var hide_profile:bool = false

var hide_name:bool = false

var hidden_names = ["", "Deadplant", "Narrarator"]

var default_inputs:Dictionary

var wait_for_signal:bool = false:
	set(new_value):
		wait_for_signal = new_value
		
		signal_wait_finished.emit()

var prepare_dialogue_two:Variant

var text_two:Variant

var name_two:Variant

# functions
func _ready() -> void:
	# remove when using another save this is just an exsample save
	load_permanent_data()
	make_node_paths()
	hide()


func run_dialouge(file:String, Conv:int):
	# To run dialouge simply for cutscences
	json_file = file
	conversation_id = Conv
	ending_conversation_id = Conv
	in_cutscene = true
	
	start_dialogue()


func start_dialogue() -> void: 
	if deactivated:
		return
	
	show()
	
	# so next time it enters the function it will imeditlly exit
	deactivated = true
	json_dialogue = load_json(json_file)
	
	if ending_conversation_id < 1 or ending_conversation_id > len(json_dialogue): 
		ending_conversation_id = len(json_dialogue) 
	
	# the line before first line in the convo because you automaticlly go up the next line when starting a convo 
	current_diauogue_id = -1
	
	next_dialogue()


func make_node_paths():
	name_box = sprites.get_child(1)
	character_name = sprites.get_child(2)
	character_icon = sprites.get_child(3)
	name_box_two = sprites_2.get_child(1)
	character_name_two = sprites_2.get_child(2)
	character_icon_two = sprites_2.get_child(3)
	
	character_name.resized.connect(update_name_box)
	character_name_two.resized.connect(update_name_box_two)


func update_name_box():
	name_box.size.x = character_name.size.x + 24


func update_name_box_two():
	name_box_two.size.x = character_name_two.size.x + 24


func load_json(filepath: String):
	if not FileAccess.file_exists(filepath):
		return
	
	var data_from_file = FileAccess.open(filepath, FileAccess.READ)
	var Result_from_File = JSON.parse_string(data_from_file.get_as_text())
	
	return Result_from_File


func _input(event: InputEvent) -> void:
	if not detect_player and not in_cutscene:
		return
	
	if event.is_action_pressed("Skip_Text") and skipable and not auto_skip:
		finish_text()
	
	if is_dialogue_runing:
		return
	
	if event.is_action_pressed("Continue") and not wait_for_responses:
		next_dialogue()


func next_dialogue():
	current_diauogue_id += 1
	
	show_responce.play("RESET") 
	dialogue_ui_2.hide()
	options.hide()
	
	if there_is_no_more_dialogue():
		stop_dialogue()
		
		# to exit out the function
		return 
	
	current_dialogue = json_dialogue[str(conversation_id)][current_diauogue_id]
	is_dialogue_runing = true
	
	# seting up dialogue
	set_up_dialogue_options()
	set_profile()
	update_text_box()
	
	if not prepare_dialogue_two:
		return
	
	update_text_box_two()


func stop_dialogue():
	hide()
	
	deactivated = false
	
	if in_cutscene:
		in_cutscene = false
	
	# if there are more conversations
	if conversation_id < ending_conversation_id:
		conversation_id += 1
	
	current_npc = null
	
	dialogue_finished.emit()


func set_up_dialogue_options():
	can_move = return_dialogue_key('can_move', false)
	skipable = return_dialogue_key('skipable', true)
	play_voice = return_dialogue_key('voice', true)
	auto_skip = return_dialogue_key('auto_skip', false)
	wait_for_responses = return_dialogue_key('choices') or return_dialogue_key('reactions')
	pause_at_ending_of_sentence = return_dialogue_key('pause_at_ending', true)
	just_show_text = return_dialogue_key('just_text', false)
	hide_profile = return_dialogue_key('hide_profile', false)
	hide_name = return_dialogue_key('hide_name', false)
	emit_custom = return_dialogue_key('signal', [false])
	wait_for_signal = return_dialogue_key('wait_for_signal', false)
	text_two = return_dialogue_key('text_two', "")
	name_two = return_dialogue_key('name_two', "")
	
	if return_dialogue_key('choice', ""):
		save_data["choices"][return_dialogue_key('choice', "")] = true
	
	prepare_dialogue_two = text_two != null and name_two != ""


func set_profile(): 
	# reset the postion and size to defaults 
	character_voice.stream = load(voice_path + "default_dialogue_voice.wav")
	sprites.visible = not just_show_text
	character_icon.visible = not hide_profile
	character_icon_two.visible = not hide_profile
	
	for names in hidden_names:
		if return_dialogue_key("name", "") == names: 
			hide_name = true
			
			break
	
	name_box.visible = not hide_name
	character_name.visible = not hide_name
	
	check_if_profile_exsist(dialogue_ui, "name", "face", 8)


func check_if_profile_exsist(UI:Control, profile_name:String, profile_face:String, aniplayer_index:int):
	var voice_name = return_dialogue_key(profile_name, "") + "_voice.wav"
	var animation_name = return_dialogue_key(profile_name, "no animation") + str(int(return_dialogue_key(profile_face, 0)))
	
	if FileAccess.file_exists(voice_path + voice_name):
		UI.get_child(2).stream = load(voice_path + voice_name.to_lower())
	
	for animation in UI.get_child(aniplayer_index).get_animation_list():
		# if animation has a profile
		if animation.contains(animation_name) and not hide_profile:
			
			UI.get_child(1).position.x = 320
			UI.get_child(1).size.x = 608
			
			UI.get_child(aniplayer_index).play(animation_name, -1, 0.0)
			
			# so it won't check for other animations after it found the spesific one
			break
		
		else:
			
			UI.get_child(aniplayer_index).play("RESET")
			
			UI.get_child(1).position.x = 208
			UI.get_child(1).size.x = 720


func update_text_box():
	# when you move on to the next line it resets the visable text to 0
	character_text.visible_ratio = 0
	character_name.text = return_dialogue_key('name', "")
	
	# if your playing the signal at the start and your waitng for the signal to finish
	if emit_custom[0] == false and wait_for_signal:
		hide()
		
		await signal_wait_finished
		
		show()
	
	# if that 'screen_position' doesnt exist it will return null
	if return_dialogue_key('screen_position', []):
		dialogue_ui.position.x = current_dialogue['screen_position'][0]
		dialogue_ui.position.y = current_dialogue['screen_position'][1]
	
	character_text.text = return_dialogue_key('text', "") 
	
	# make the charcter text scroll after you set it
	scrolling_text(character_text, return_dialogue_key('speed', 0.05))


func update_text_box_two():
	check_if_profile_exsist(dialogue_ui_2, 'name_two', "face_two", 3)
	
	character_text_two.visible_ratio = 0
	character_name_two.text = name_two
	character_text_two.text = text_two
	
	dialogue_ui_2.show()
	
	scrolling_text(character_text_two, return_dialogue_key('speed_two', 0.05))


func scrolling_text(text_node:RichTextLabel, speed = 0.05):
	var voice_played = 0
	var parsed_text_length = text_node.get_parsed_text().length()
	var should_you_play_voice = play_voice
	
	play_profile_animations()
	
	# for every character in character text
	for chara in text_node.get_text():
		
		# make one character visable (visable text includes spaces)
		text_node.visible_characters += 1
		play_voice = should_you_play_voice
		
		# have a long pasue for characters that signify the end of sentece
		for s in pause_at_character:
			if pause_at_ending_of_sentence and chara == s:
				# if the character signifies the end of sentece wait a 0.3 seconds
				await get_tree().create_timer(0.3).timeout
		
		# dont play a sound for silent characters like periods
		for c in silent_characters:
			if chara == c:
				play_voice = false 
		
		# and to make sure the sound doenst play when counting the bbcode text 
		if play_voice == true and voice_played <= parsed_text_length:
			voice_played += 1
			
			character_voice.play()
			
			if prepare_dialogue_two and text_node == character_text_two:
				character_voice_2.play()
		
		play_voice = true
		
		# wait every 0.05 seconds to repet the loop and add another character
		await get_tree().create_timer(speed).timeout 
		
		# to avoid any delay when all the text is clearly visable:
		# if all the parse (visable) text it shown make add all the unprasied (hidden) text too
		if text_node.visible_characters >= parsed_text_length:
			text_node.visible_characters = text_node.text.length()
			
			break
	
	stop_profile_animations()
	
	# if all the text is shown (including dialogue box 2).
	if text_node.visible_characters == text_node.text.length():
		
		if prepare_dialogue_two and not dialogue_ui_2.get_child(1).visible_ratio == 1.0:
			return
		
		when_dialogue_finishes()


func finish_text():
	character_text.visible_characters = character_text.text.length()
	character_text_two.visible_characters = character_text_two.text.length()


func play_profile_animations():
	profile_animation.play(profile_animation.current_animation)
	
	if not prepare_dialogue_two:
		return
	
	profile_animation_2.play(profile_animation_2.current_animation) 


func stop_profile_animations():
	profile_animation.stop()
	
	if not prepare_dialogue_two:
		return
	
	profile_animation_2.stop()


func when_dialogue_finishes():
	# if responses doesnt exist it will return null
	if return_dialogue_key('choices'):
		
		choices_exsist = true
		
		add_respones()
		show_choices()
	
	# if emit_signal_after_dialogue = true
	# if your playing the signal at the end then your waitng for the signal to finish before hiding the dialogue
	if emit_custom[0] == true:
		emit_signal(emit_custom[1])
	
	is_dialogue_runing = false
	
	check_for_waiting()


func add_respones():
	choice_responses = current_dialogue['responses']
	
	if return_dialogue_key('aftermath'):
		choice_aftermath = current_dialogue['aftermath']
	
	else:
		# if theirs no set aftermath then set it to the origanl ending conversation
		choice_aftermath = [ending_conversation_id, ending_conversation_id, ending_conversation_id, ending_conversation_id]


func check_for_waiting():
	# after dialouge
	# if there are no choices yet you wait for responses there are reactions 
	if not choices_exsist and wait_for_responses:
		show_reactions() 
	
	if auto_skip:
		await get_tree().create_timer(return_dialogue_key("auto_skip_wait", 0)).timeout
		
		next_dialogue()


func show_choices():
	var choices:Array = current_dialogue['choices']
	
	# reset Options text
	for b in options.get_children():
		if b is Button:
			b.text = ""
	
	# default position for the choice nodes
	options.position = Vector2(168, 500) 
	
	if not character_text.text == "":
		options.position = Vector2(200, 536)
	
	for b in options.get_children():
		if not b is Button:
			return
		
		var index = b.get_index()
		
		options.get_child(index).visible = false
		
		# Make sure theres a reaction text
		if choices.size() > index and not choices[index] == "":
			options.show()
			
			options.get_child(index).visible = true
			options.get_child(index).text = choices[index]
			
			if choices.size() == 1:
				options.get_child(0).grab_focus()
			
			if choice_responses[index] != 0:
				options.get_child(index).pressed.connect(func():
					make_choice_current_dialouge(index)
					)
			 
			else:
				dialogue_finished.emit()
				
				return


func make_choice_current_dialouge(choice):
	conversation_id = int(choice_responses[choice])
	
	if not in_cutscene:
		# if your not in a cutscene (thiers an npc) set the npc instance to the aftermath.
		save_data["npc_instance"][current_npc] = int(choice_aftermath[choice])
		ending_conversation_id = int(choice_responses[choice])
	
	choices_exsist = false
	deactivated = false
	
	start_dialogue()
	
	choice_was_made.emit()


func show_reactions():
	var react = 0
	var move_index_up_by = 0
	
	for reaction in reactions:
		if move_index_up_by >= current_dialogue['reactions'].size():
			break
		
		var png_name = str(current_dialogue['reactions'][0 + move_index_up_by]).to_lower() + "_profile.png"
		var reaction_image = reactions[react].get_child(0)
		var reaction_text = reactions[react].get_child(1)
		
		reaction_image.texture = null
		reaction_text.text = ""
		
		if FileAccess.file_exists(profile_path + png_name):
			reaction_image.texture = load(profile_path + png_name)
			reaction_image.frame = int(current_dialogue['reactions'][1 + move_index_up_by])
		
		reaction_text.text = return_dialogue_key('reactions', ["",0,""])[2 + move_index_up_by]
		react += 1
		move_index_up_by += 3
	
	if not reactions[0].get_child(1).text == "[Inset litraly any respone]": 
		show_responce.play("slide in")
		
		await show_responce.animation_finished
		
		# to make sure that it only runs after "slide in", in no other animation 
		wait_for_responses = false


func _on_overlap_detection_body_entered(_body: Node2D) -> void:
	if visible == false:
		dialogue_ui.position.y = -464


func _on_overlap_detection_body_exited(_body: Node2D) -> void:
	if visible == false:
		dialogue_ui.position = Vector2.ZERO


func _on_overlap_detection_area_entered(_area: Area2D) -> void:
	if  visible == false:
		dialogue_ui.position.y = -464


func _on_overlap_detection_area_exited(_area: Area2D) -> void:
	if visible == false:
		dialogue_ui.position = Vector2.ZERO


func load_permanent_data():
	var config:ConfigFile = ConfigFile.new()
	
	if config.load(PERMENENT_PATH) != OK:
		return
	
	for section in save_data:
		# load if cutscene ran
		if config.has_section(section):
			for Key in config.get_section_keys(section): 
				save_data[section][Key] = config.get_value(section, Key)


func permenently_save_data():
	var config:ConfigFile = ConfigFile.new()
	
	for section in save_data:
		# save if cutscene ran
		for key in save_data[section]:
			config.set_value(section, key, save_data[section][key])
	
	config.save(PERMENENT_PATH)


func remove_player_input():
	# create a key with the name of the action and add the intupt as a value 
	for Action in InputMap.get_actions():
		default_inputs[Action] = InputMap.action_get_events(Action)
		
		# erase the inputs in the current action 
		InputMap.action_erase_events(Action) 


func add_player_input():
	# for every event in the current action add it back
	for Action in InputMap.get_actions():
		
		for input in default_inputs[Action]:
			InputMap.action_add_event(Action, input) 


func there_is_no_more_dialogue():
	return current_diauogue_id >= len(json_dialogue[str(conversation_id)])


func return_dialogue_key(key, default = null):
	return current_dialogue.get(key, default)
