class_name dialoguesystemnode extends CanvasLayer

# signal
signal dialogue_finished
signal update_godot_dialogue
#node variables
@onready var dialogue_ui = $"Dialogue UI"
@onready var Sprites: Control = $"Dialogue UI/Sprites"
@onready var overlap_detection: Area2D = $"Overlap Detection"
@onready var Character_Text = $"Dialogue UI/Character Text"
@onready var profile_animations: AnimationPlayer = $"Profile animations"
@onready var Character_Voice: AudioStreamPlayer2D = $"Dialogue UI/Voice"
@onready var options = $"Dialogue UI/Options"
@onready var reaction_text = $"Dialogue UI/Reaction 1/Reaction text"
@onready var show_responce: AnimationPlayer = $"Show Responce"
@onready var Reactions = [$"Dialogue UI/Reaction 1", $"Dialogue UI/Reaction 2", $"Dialogue UI/Reaction 3", $"Dialogue UI/Reaction 4"]
# variables
# Nesasary variables
@export_file("*.json") var Json_file
@export var Profile_path = "res://Sprites/Character's/"
@export var Voice_path = "res://Audio/"
const temp_save_Path = "res://save_conv_temp.cfg" # the data is saved across scenes untill the game is closed 
var Detect_Player:bool = false
var Dialogue = []
var Default_Conversation_ID = 1
var Default_Ending_Conversation =  0
var Ending_Conversation = Default_Ending_Conversation
var conversation_id = Default_Conversation_ID
var Default_Dialogue_ID = 0
var current_diauogue_id = Default_Dialogue_ID
var in_current_dialogue 
var choices_exsist = false
var Choice_Responces:Array
var Choice_Aftermath:Array
var Deactivated = false
var is_dialogue_runing = true
var has_dialogue_ran = false
var Profile_index = 1

# option variables
@export var Debug_output:bool 
var in_Cutscene = false
var can_move = false
var emit_custom:Array = [false]:
	set(new_value):
		emit_custom = new_value # nessasary
		if emit_custom.size() == 2 and emit_custom[0] == false: # play_at_end = false
			emit_signal(emit_custom[1])
var default_volume_db = 0.0
var skipable = true 
var play_voice = true
var auto_skip = false
var wait_for_responses = false
var pause_at_character = [",", "-", ";", ":", ".", "?", "!"]
var pause_at_ending_of_sentence = true
var pause_at_index = []
var silent_characters = [" ","!",",", "-", ".", "?",";", '"', "©", "™", "[", "]"]
var just_show_text = false
var hide_profile = false

func _ready() -> void:
	if FileAccess.file_exists(temp_save_Path): DirAccess.remove_absolute(temp_save_Path)
	hide()

func Run_dialouge(file:String, Conv:int): # To run certin dialouge simpley
	Json_file = file
	conversation_id = Conv
	Ending_Conversation = Conv
	in_Cutscene = true
	start_dialogue()

func start_dialogue() -> void: 
	if Debug_output: print("Deactivated: "+ str(Deactivated))
	if Deactivated: return
	
	Sprites.visible = not just_show_text
	Sprites.get_child(3).visible = not hide_profile
	show_responce.play("RESET") # so the responce hides when you run the same dialouge 
	show()
	Deactivated = true # so next time it enters the function it wit imeditly exit
	Dialogue = load_Json(Json_file)
	
	if Ending_Conversation < 1 or Ending_Conversation > len(Dialogue): 
		Ending_Conversation = len(Dialogue) 
	 
	current_diauogue_id = -1 # first dialogue line in JSON 
	Next_Dialogue()
	

func load_Json(filepath: String):
	if FileAccess.file_exists(filepath):
		var data_from_file = FileAccess.open(filepath, FileAccess.READ)
		var Result_from_File = JSON.parse_string(data_from_file.get_as_text())
		return Result_from_File
	


func _input(event: InputEvent) -> void:
	if Detect_Player or in_Cutscene and not is_dialogue_runing:
		if has_dialogue_ran and event.is_action_pressed("Continue") and not wait_for_responses:
			Next_Dialogue()
		


func Next_Dialogue():
	current_diauogue_id += 1
	options.hide()
	
	if current_diauogue_id  >= len(Dialogue[str(conversation_id)]): # if thers no more dialogue
		Deactivated = false
		hide()
		
		if conversation_id < Ending_Conversation:  # if there are more conversations
			conversation_id += 1
		
		dialogue_finished.emit()
		
		return # to exit out the function
	
	in_current_dialogue = Dialogue[str(conversation_id)][current_diauogue_id]
	is_dialogue_runing = true
	has_dialogue_ran = false
	
	# seting up dialogue
	set_up_dialogue_options()
	Set_Profile()
	set_text()


func set_up_dialogue_options():
	Profile_index = int(in_current_dialogue.get('Face', 0)) 
	Character_Voice.volume_db = in_current_dialogue.get('volume', 0.0)
	can_move = in_current_dialogue.get('can move', false)
	skipable = in_current_dialogue.get('skipable', true)
	play_voice = in_current_dialogue.get('voice', true)
	auto_skip = in_current_dialogue.get('Auto Skip', false)
	wait_for_responses = in_current_dialogue.get('Choices') or in_current_dialogue.get('Reactions')
	pause_at_ending_of_sentence =  in_current_dialogue.get('pause at ending', true)
	just_show_text = in_current_dialogue.get('just text', false)
	hide_profile = in_current_dialogue.get('hide profile', false)
	pause_at_index = in_current_dialogue.get('pause')
	emit_custom = in_current_dialogue.get('Signal', [false])
	


func Set_Profile(): # runs befor options are set
	Character_Text.visible_ratio = 0 # when you change your character profile reste the visable text to 0
	# reset the postion and size to defaults 
	Character_Voice.stream = load(Voice_path + "Default dialogue voice.wav")
	
	Sprites.get_child(2).text = in_current_dialogue["Name"]
	
	if FileAccess.file_exists(Voice_path + str(in_current_dialogue['Name']) + " voice.wav"):
		Character_Voice.stream = load(Voice_path + str(in_current_dialogue['Name']) + " voice.wav")
	
	for animation in profile_animations.get_animation_list():
		var Full_name = in_current_dialogue['Name'] + str(Profile_index)
		if animation.contains(Full_name):
			#print(Full_name)
			Character_Text.position.x = 320
			Character_Text.size.x = 608
			profile_animations.play(Full_name, -1, 0.0)
			break # so it donet cheak for other animations after it found the spisific one
		else:
			#print("Full_name")
			profile_animations.play("RESET")
			Character_Text.position.x = 208
			Character_Text.size.x = 720
			
			

func set_text():
	if in_current_dialogue.get('Screen position', []):# if that 'Screen_position' doesnt exist it will return null
		dialogue_ui.position.x = in_current_dialogue['Screen position'][0]
		dialogue_ui.position.y = in_current_dialogue['Screen position'][1]
	
	Character_Text.text = in_current_dialogue['Text'] 
	scrolling_text(Character_Text, in_current_dialogue.get('Speed', 0.05)) # make the charcter text scroll after you set it



func scrolling_text(text_node:RichTextLabel, Speed = 0.05):
	var voice_played = 0
	var parsed_text_length = text_node.get_parsed_text().length()
	for e in text_node.get_text(): # scroling text, for every letter in character text
		text_node.visible_characters += 1 # make one character visable (visable text includes spaces)
		if is_dialogue_runing:
			profile_animations.stop()
			
			if pause_at_index != null:
				for p in pause_at_index: # for ever value in "pause_at_index"
					if int(p) == text_node.visible_characters: # if the index is the amount of visab;e characters shown 
						await get_tree().create_timer(0.3).timeout # then wait for 0.3 sec 
			
			for s in pause_at_character:
				if pause_at_ending_of_sentence and e == s: # Long pasues at the End of sentece
					# if the character is these letter wait a little more
					await get_tree().create_timer(0.3).timeout
			
			for c in silent_characters:
				if e == c:
					play_voice = false
			
			if e != " ":
				profile_animations.play(profile_animations.current_animation) 
			
			if play_voice == true and voice_played <= parsed_text_length: # to make sure the sound doenst play when counting the bbcode text 
				voice_played += 1
				Character_Voice.play()
			
			play_voice = true
		if Debug_output:print(e)
		
		await get_tree().create_timer(Speed).timeout #every  0.05 seconds times the length of the text 
		
		Sprites.get_child(1).size.x = Sprites.get_child(2).size.x + 24
		
		if text_node.visible_characters >= parsed_text_length or Input.is_action_pressed("Skip_Text") and skipable and not auto_skip: # if the text is skiped or all the parse text it shown
			text_node.visible_characters = text_node.text.length() # set the visable characters to the full length
			break # exit out of for loop
	
	if text_node.visible_characters == text_node.text.length(): # if all the text is showen.
		if Debug_output:print("finised")
		# if that 'Responses' doesnt exist it will return null
		if not current_diauogue_id  >= len(Dialogue[str(conversation_id)]) and in_current_dialogue.get('Choices'):# when pressing the skip button to fast it crashesx
			if Debug_output: print(in_current_dialogue['Choices'])
			choices_exsist = true
			Choice_Responces = in_current_dialogue['Responses']
			Choice_Aftermath = in_current_dialogue['Aftermath']
			show_choices()
		
		if emit_custom[0] == true: # play_at_end = true
			emit_signal(emit_custom[1])
		
		is_dialogue_runing = false
		has_dialogue_ran = true
		
		# after dialouge 
		if not choices_exsist: show_reactions() #if there are choices there can be any Reactions
		if auto_skip: Next_Dialogue()
	

func show_choices():
	# variables
	var Choices:Array = in_current_dialogue['Choices']
	# reset options text
	for b in options.get_children():
		if b is Button:
			b.text = ""
	
	options.position = Vector2(200, 504) # default posioton
	if Choices[2] == "" and Choices[3] == "":
		options.position = Vector2(200, 536)
	
	for b in options.get_children():
		var index = b.get_index()
		if b is Button:
			options.get_child(index).visible = false
			if not Choices[index] == "": # Make sure theres a reaction text
				options.show()
				options.get_child(index).visible = true
				options.get_child(index).text = Choices[index]
				
				if Choices.size() == 1: options.get_child(0).grab_focus()
				
				if Debug_output: print(options.get_child(index).text)
				
				if Choice_Responces[index] != 0:
					options.get_child(index).pressed.connect(func():
						change_to_choice_dialouge(index)
						) 
				else: 
					if Debug_output: print("choice " + str(b.get_index()) + " exit")
					dialogue_finished.emit()
					return # to exit out the function


func show_reactions():
	var react = 0
	var move_index_up_by = 0
	if in_current_dialogue.get('Reactions'):
		for R in Reactions:
			if move_index_up_by >= in_current_dialogue['Reactions'].size(): break
			
			Reactions[react].get_child(1).text = ""
			if FileAccess.file_exists(Profile_path + str(in_current_dialogue['Reactions'][0 + move_index_up_by]) + " Profile.png"):
				Reactions[react].get_child(0).texture = load(Profile_path + str(in_current_dialogue['Reactions'][0 + move_index_up_by]) + " Profile.png")
				Reactions[react].get_child(0).frame = int(in_current_dialogue['Reactions'][1 + move_index_up_by])
			
			Reactions[react].get_child(1).text =  in_current_dialogue.get('Reactions', ["",0,""])[2 + move_index_up_by]
			react += 1
			move_index_up_by += 3
	
	if not Reactions[0].get_child(1).text == "[Inset litraly any respone]": 
		show_responce.play("slide in")
		await show_responce.animation_finished
		wait_for_responses = false # to make sure that it only runs after "slide in", in no other animation 
	


func _on_overlap_detection_body_entered(body: Node2D) -> void:
	if visible == false:
		dialogue_ui.position.y = -456

func _on_overlap_detection_body_exited(body: Node2D) -> void:
	if visible == false:
		dialogue_ui.position = Vector2.ZERO


func _on_overlap_detection_area_entered(area: Area2D) -> void:
	if  visible == false:
		dialogue_ui.position.y = -456

func change_to_choice_dialouge(choice): # cannot get path to 'Responses' in  this function spisificly
	conversation_id = int(Choice_Responces[choice])
	if Debug_output: print("choice " + str(choice) + ", conversation id: " + str(conversation_id))
	Ending_Conversation = int(Choice_Aftermath[choice])
	if Debug_output: print("choice " + str(choice) + ", ending_conversation id: " + str(Ending_Conversation))
	choices_exsist = false
	Deactivated = false
	start_dialogue()

func _on_overlap_detection_area_exited(area: Area2D) -> void:
	if visible == false:
		dialogue_ui.position = Vector2.ZERO
