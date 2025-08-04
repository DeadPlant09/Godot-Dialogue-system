class_name dialoguesystemnode extends CanvasLayer

# signal
signal dialogue_finished
signal signal_wait_finshed

# custom signals
signal update_godot_dialogue

# node variables
@onready var dialogue_ui = $"Dialogue UI"
@onready var overlap_detection: Area2D = $"Overlap Detection"
@onready var Sprites: Control = dialogue_ui.get_child(0)
@onready var Character_Text = dialogue_ui.get_child(1)
@onready var Character_Voice: AudioStreamPlayer2D = dialogue_ui.get_child(2)
@onready var Options = dialogue_ui.get_child(3)
@onready var Reactions = [dialogue_ui.get_child(4), dialogue_ui.get_child(5), dialogue_ui.get_child(6), dialogue_ui.get_child(7)]
@onready var profile_animations: AnimationPlayer = dialogue_ui.get_child(8)
@onready var show_responce: AnimationPlayer = dialogue_ui.get_child(9)


# variables
# Nesasary variables
@export_file("*.json") var Json_file
@export var Profile_path = "res://Sprites/Character's/"
@export var Voice_path = "res://Audio/"
@export var Debug_output:bool 
const temp_save_Path = "res://save_conv_temp.cfg" # the data is saved across scenes untill the game is closed 
var Detect_Player:bool = false
var Dialogue = []
var Default_Conversation_ID = 1
var Default_Ending_Conversation =  0
var Ending_Conversation = Default_Ending_Conversation
var Conversation_id = Default_Conversation_ID
var Default_Dialogue_ID = 0
var Current_Diauogue_id = Default_Dialogue_ID
var Choice_Responces:Array
var Choice_Aftermath:Array
var Deactivated = false
var Is_Dialogue_Runing = false
var choices_exsist = false
var current_dialogue 

# option variables
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
var hide_name = false
var hidden_names = ["", "Deadplant", "Narrarator"]
var wait_signal_finshed = false:
	set(new_value):
		wait_signal_finshed = new_value # nessasary
		signal_wait_finshed.emit()
var text_2
var name_2
var face_2

func _ready() -> void:
	if FileAccess.file_exists(temp_save_Path): DirAccess.remove_absolute(temp_save_Path)
	hide()


func Run_dialouge(file:String, Conv:int): # To run certin dialouge simply
	Json_file = file
	Conversation_id = Conv
	Ending_Conversation = Conv
	in_Cutscene = true
	start_dialogue()


func start_dialogue() -> void: 
	if Debug_output: print("Deactivated: "+ str(Deactivated))
	if Deactivated: return
	
	show_responce.play("RESET") # so the responce hides when you run the same dialouge 
	show()
	Deactivated = true # so next time it enters the function it wit imeditly exit
	Dialogue = load_Json(Json_file)
	
	if Ending_Conversation < 1 or Ending_Conversation > len(Dialogue): 
		Ending_Conversation = len(Dialogue) 
	 
	Current_Diauogue_id = -1 # first dialogue line in JSON 
	Next_Dialogue()
	


func load_Json(filepath: String):
	if FileAccess.file_exists(filepath):
		var data_from_file = FileAccess.open(filepath, FileAccess.READ)
		var Result_from_File = JSON.parse_string(data_from_file.get_as_text())
		return Result_from_File
	


func _input(event: InputEvent) -> void:
	if not Detect_Player and not in_Cutscene or Is_Dialogue_Runing: return
	if event.is_action_pressed("Continue") and not wait_for_responses:
		Next_Dialogue()


func Next_Dialogue():
	Current_Diauogue_id += 1
	$"Dialogue UI 2".hide()
	Options.hide()
	
	if Current_Diauogue_id  >= len(Dialogue[str(Conversation_id)]): # if thers no more dialogue
		Deactivated = false
		hide()
		
		if Conversation_id < Ending_Conversation:  # if there are more conversations
			Conversation_id += 1
		
		dialogue_finished.emit()
		
		return # to exit out the function
	
	current_dialogue = Dialogue[str(Conversation_id)][Current_Diauogue_id]
	Is_Dialogue_Runing = true
	
	# seting up dialogue
	set_up_dialogue_Options()
	Set_Profile()
	set_text()


func set_up_dialogue_Options():
	Character_Voice.volume_db = current_dialogue.get('volume', 0.0)
	can_move = current_dialogue.get('can move', false)
	skipable = current_dialogue.get('skipable', true)
	play_voice = current_dialogue.get('voice', true)
	auto_skip = current_dialogue.get('auto skip', false)
	wait_for_responses = current_dialogue.get('Choices') or current_dialogue.get('Reactions')
	pause_at_ending_of_sentence =  current_dialogue.get('pause at ending', true)
	just_show_text = current_dialogue.get('just text', false)
	hide_profile = current_dialogue.get('hide profile', false)
	pause_at_index = current_dialogue.get('pause')
	hide_name = current_dialogue.get('hide name', false)
	emit_custom = current_dialogue.get('Signal', [false])
	wait_signal_finshed = current_dialogue.get('wait signal', false)
	text_2 = current_dialogue.get('text_2')
	name_2 = current_dialogue.get('name_2',"")
	face_2 = current_dialogue.get('face_2')


func Set_Profile(): # runs befor Options are set
	Character_Text.visible_ratio = 0 # when you change your character profile reste the visable text to 0
	# reset the postion and size to defaults 
	Character_Voice.stream = load(Voice_path + "Default dialogue voice.wav")
	
	Sprites.visible = not just_show_text
	Sprites.get_child(3).visible = not hide_profile
	
	for names in hidden_names:
		if current_dialogue.get("Name", "") == names: 
			hide_name = true
			break
	
	Sprites.get_child(1).visible = not hide_name
	Sprites.get_child(2).visible = not hide_name
	
	check_if_profile_exsist()


func check_if_profile_exsist():
	if FileAccess.file_exists(Voice_path + str(current_dialogue.get("Name")) + " voice.wav"):
		Character_Voice.stream = load(Voice_path + str(current_dialogue['Name']) + " voice.wav")
	
	for animation in profile_animations.get_animation_list():
		var Full_name = current_dialogue.get("Name", "no animation") + str(int(current_dialogue.get('Face', 0)))
		if animation.contains(Full_name):
			if Debug_output: print("animation: " + Full_name)
			Character_Text.position.x = 320
			Character_Text.size.x = 608
			profile_animations.play(Full_name, -1, 0.0)
			break # so it donet cheak for other animations after it found the spisific one
		else:
			if Debug_output: print("animation: "+ "RESET")
			profile_animations.play("RESET")
			Character_Text.position.x = 208
			Character_Text.size.x = 720


func set_text():
	if emit_custom[0] == false and wait_signal_finshed:
		hide()
		await signal_wait_finshed
		show()
	
	Sprites.get_child(2).text = current_dialogue.get('Name', "")
	$"Dialogue UI 2".get_child(0).get_child(2).text = name_2
	await get_tree().process_frame
	await get_tree().process_frame
	Sprites.get_child(1).size.x = Sprites.get_child(2).size.x + 24 # updating the size of the name box
	$"Dialogue UI 2".get_child(0).get_child(1).size.x = $"Dialogue UI 2".get_child(0).size.x + 24
	
	if current_dialogue.get('Screen position', []):# if that 'Screen_position' doesnt exist it will return null
		dialogue_ui.position.x = current_dialogue['Screen position'][0]
		dialogue_ui.position.y = current_dialogue['Screen position'][1]
	
	Character_Text.text = current_dialogue.get('Text', "") 
	scrolling_text(Character_Text, current_dialogue.get('Speed', 0.05)) # make the charcter text scroll after you set it
	if text_2 != null and dialogue_ui != $"Dialogue UI 2":
		$"Dialogue UI 2".show()
		scrolling_text($"Dialogue UI 2".get_child(1), current_dialogue.get('speed 2', 0.05))


func scrolling_text(text_node:RichTextLabel, Speed = 0.05):
	var voice_played = 0
	var parsed_text_length = text_node.get_parsed_text().length()
	
	for e in text_node.get_text(): # scroling text, for every letter in character text
		text_node.visible_characters += 1 # make one character visable (visable text includes spaces)
		
		profile_animations.stop()
		
		if pause_at_index != null:
			for p in pause_at_index: # for ever value in "pause_at_index"
				if int(p) == text_node.visible_characters: # if the index is the amount of visab;e characters shown 
					await get_tree().create_timer(0.3).timeout # then wait for 0.3 sec 
		
		for s in pause_at_character:
			if pause_at_ending_of_sentence and e == s: # Long pasues at the End of sentece
				# if the character is these letter wait a little more
				await get_tree().create_timer(0.3).timeout
		
		for c in silent_characters: # it wont play the sound for certine characters
			if e == c:
				play_voice = false 
		
		if play_voice == true and voice_played <= parsed_text_length: # to make sure the sound doenst play when counting the bbcode text 
			voice_played += 1
			Character_Voice.play()
			profile_animations.play(profile_animations.current_animation) # the talking animation wont play for silent characters
		
		play_voice = true
		if Debug_output:print(e)
		
		await get_tree().create_timer(Speed).timeout # wait every 0.05 seconds to repet the loop 
		
		if text_node.visible_characters >= parsed_text_length or Input.is_action_pressed("Skip_Text") and skipable and not auto_skip: # if the text is skiped or all the parse text it shown
			text_node.visible_characters = text_node.text.length() # set the visable characters to the full length
			break # exit out of for loop
	
	
	if text_node.visible_characters == text_node.text.length(): # if all the text is shown.
		if Debug_output: print("finised dialogue")
		when_dialogue_finishes()


func when_dialogue_finishes():
	# if that 'Responses' doesnt exist it will return null
	if not Current_Diauogue_id  >= len(Dialogue[str(Conversation_id)]) and current_dialogue.get('Choices'):# when pressing the skip button to fast it crashesx
		if Debug_output: print(current_dialogue['Choices'])
		
		choices_exsist = true
		Choice_Responces = current_dialogue['Responses']
		Choice_Aftermath = current_dialogue['Aftermath']
		show_choices()
	
	if emit_custom[0] == true: # play_at_end = true
		emit_signal(emit_custom[1])
	
	Is_Dialogue_Runing = false
	
	# after dialouge 
	if not choices_exsist: show_reactions() #if there are choices there can be any Reactions
	if auto_skip: Next_Dialogue()


func show_choices():
	# variables
	var Choices:Array = current_dialogue['Choices']
	# reset Options text
	for b in Options.get_children():
		if b is Button:
			b.text = ""
	# if move_index_up_by >= current_dialogue['Reactions'].size(): break
	Options.position = Vector2(168, 500) # default posioton
	
	if not Character_Text.text == "":
		Options.position = Vector2(200, 536)
	
	for b in Options.get_children():
		
		if not b is Button: return
		var index = b.get_index()
		Options.get_child(index).visible = false
		
		if Choices.size() > index and not Choices[index] == "": # Make sure theres a reaction text
			Options.show()
			Options.get_child(index).visible = true
			Options.get_child(index).text = Choices[index]
			
			if Choices.size() == 1: Options.get_child(0).grab_focus()
			
			if Debug_output: print(Options.get_child(index).text)
			
			if Choice_Responces[index] != 0:
				Options.get_child(index).pressed.connect(func():
					change_to_choice_dialouge(index)
					) 
			else: 
				if Debug_output: print("choice " + str(b.get_index()) + " exit")
				dialogue_finished.emit()
				return # to exit out the function


func show_reactions():
	var react = 0
	var move_index_up_by = 0
	if current_dialogue.get('Reactions'):
		for R in Reactions:
			if move_index_up_by >= current_dialogue['Reactions'].size(): break
			
			Reactions[react].get_child(1).text = ""
			if FileAccess.file_exists(Profile_path + str(current_dialogue['Reactions'][0 + move_index_up_by]) + " Profile.png"):
				Reactions[react].get_child(0).texture = load(Profile_path + str(current_dialogue['Reactions'][0 + move_index_up_by]) + " Profile.png")
				Reactions[react].get_child(0).frame = int(current_dialogue['Reactions'][1 + move_index_up_by])
			
			Reactions[react].get_child(1).text =  current_dialogue.get('Reactions', ["",0,""])[2 + move_index_up_by]
			react += 1
			move_index_up_by += 3
	
	if not Reactions[0].get_child(1).text == "[Inset litraly any respone]": 
		show_responce.play("slide in")
		await show_responce.animation_finished
		wait_for_responses = false # to make sure that it only runs after "slide in", in no other animation 


func _on_overlap_detection_body_entered(body: Node2D) -> void:
	if visible == false:
		dialogue_ui.position.y = -464


func _on_overlap_detection_body_exited(body: Node2D) -> void:
	if visible == false:
		dialogue_ui.position = Vector2.ZERO


func _on_overlap_detection_area_entered(area: Area2D) -> void:
	if  visible == false:
		dialogue_ui.position.y = -464


func change_to_choice_dialouge(choice): # cannot get path to 'Responses' in  this function spisificly
	Conversation_id = int(Choice_Responces[choice])
	if Debug_output: print("choice " + str(choice) + ", conversation id: " + str(Conversation_id))
	Ending_Conversation = int(Choice_Aftermath[choice])
	if Debug_output: print("choice " + str(choice) + ", ending_conversation id: " + str(Ending_Conversation))
	choices_exsist = false
	Deactivated = false
	start_dialogue()


func _on_overlap_detection_area_exited(area: Area2D) -> void:
	if visible == false:
		dialogue_ui.position = Vector2.ZERO
