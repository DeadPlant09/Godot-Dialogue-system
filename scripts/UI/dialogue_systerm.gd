class_name dialoguesystemnode extends CanvasLayer

# signal
signal dialogue_finished
#node variables
@onready var dialogue_ui = $"Dialogue UI"
@onready var sprites: Control = $"Dialogue UI/Sprites"
@onready var overlap_detection: Area2D = $"Overlap Detection"
@onready var Character_Text = $"Dialogue UI/RichTextLabel"
@onready var profile_animations: AnimationPlayer = $"Profile animations"
@onready var Character_Voice: AudioStreamPlayer2D = $"Dialogue UI/Voice"
@onready var options = $"Dialogue UI/Options"
@onready var react_profile = $"Dialogue UI/React Profile"
@onready var reaction_text = $"Dialogue UI/Reaction text"
@onready var show_responce: AnimationPlayer = $"Show Responce"

# variables
# Nesasary variables
@export_file("*.json") var Json_file
var Detect_Player:bool = false
var Dialogue = []
var Default_Conversation_ID = 1
var Default_Ending_Conversation =  0
var Ending_Conversation = Default_Ending_Conversation
var conversation_id = Default_Conversation_ID
var Default_Dialogue_ID = 0
var current_diauogue_id = Default_Dialogue_ID
var choices_exsist = false
var Choice_Responces:Array
var Choice_Aftermath:Array
var Deactivated = false
var is_dialogue_runing = true
var has_dialogue_ran = false
var Profile_index = 1
@export var Profile_path = "res://Sprites/Character's/"
@export var Voice_path = "res://Audio/"
# option variables
@export var Debug_output:bool 
var In_Cutscene = false
var default_volume_db = 0.0
var skipable = true 
var play_voice = true
var auto_skip = false
var wait_for_chocies = false
var pause_at_character = [",", "-", ";", ":", ".", "?", "!"]
var pause_at_ending_of_sentence = true
var pause_at_index = []
var silent_characters = [" ","!",",", "-", ".", "?",";", '"', "©", "™", "[", "]"]
var just_show_text = false

func _ready() -> void:
	hide()

func Run_dialouge(file:String, Conv:int): # To run certin dialouge simpley
	Json_file = file
	conversation_id = Conv
	Ending_Conversation = Conv
	In_Cutscene = true
	start_dialogue()

func start_dialogue() -> void: 
	if Debug_output: 
		print("new dialouge")
		print("Deactivated: "+ str(Deactivated))
	if Deactivated:
		return
	
	sprites.visible = not just_show_text
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
	if Detect_Player or In_Cutscene and not is_dialogue_runing:
		if has_dialogue_ran and event.is_action_pressed("Continue") and not wait_for_chocies:
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
	
	is_dialogue_runing = true
	has_dialogue_ran = false
	
	# seting up dialogue
	set_up_dialogue_options()
	Set_Profile()
	set_text()

func set_up_dialogue_options():
	Profile_index = int(Dialogue[str(conversation_id)][current_diauogue_id].get('Face', 0)) 
	Character_Voice.volume_db = Dialogue[str(conversation_id)][current_diauogue_id].get('volume', 0.0)
	skipable = Dialogue[str(conversation_id)][current_diauogue_id].get('skipable', true)
	play_voice = Dialogue[str(conversation_id)][current_diauogue_id].get('voice', true)
	auto_skip = Dialogue[str(conversation_id)][current_diauogue_id].get('Auto Skip', false)
	wait_for_chocies = Dialogue[str(conversation_id)][current_diauogue_id].get('Choices')
	pause_at_ending_of_sentence =  Dialogue[str(conversation_id)][current_diauogue_id].get('pause at ending', true)
	just_show_text = Dialogue[str(conversation_id)][current_diauogue_id].get('just text', false)
	reaction_text.text =  Dialogue[str(conversation_id)][current_diauogue_id].get('reactions', ["",0,""])[2]
	pause_at_index = Dialogue[str(conversation_id)][current_diauogue_id].get('pause')
	

func Set_Profile(): # runs befor options are set
	Character_Text.visible_ratio = 0 # when you change your character profile reste the visable text to 0
	# reset the postion and size to defaults 
	Character_Voice.stream = load(Voice_path + "Default dialogue voice.wav")
	#print("reset")
	
	if FileAccess.file_exists(Voice_path + str(Dialogue[str(conversation_id)][current_diauogue_id]['Name']) + " voice.wav"):
		Character_Voice.stream = load(Voice_path + str(Dialogue[str(conversation_id)][current_diauogue_id]['Name']) + " voice.wav")
	
	for animation in profile_animations.get_animation_list():
		var Full_name = Dialogue[str(conversation_id)][current_diauogue_id]['Name'] + str(Profile_index)
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
	if Dialogue[str(conversation_id)][current_diauogue_id].get('Screen position', []):# if that 'Screen_position' doesnt exist it will return null
		dialogue_ui.position.x = Dialogue[str(conversation_id)][current_diauogue_id]['Screen position'][0]
		dialogue_ui.position.y = Dialogue[str(conversation_id)][current_diauogue_id]['Screen position'][1]
	
		
	Character_Text.text = Dialogue[str(conversation_id)][current_diauogue_id]['Text'] 
	scrolling_text(Character_Text, Dialogue[str(conversation_id)][current_diauogue_id].get('Speed', 0.05)) # make the charcter text scroll after you set it
	


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
			
			if play_voice == true: profile_animations.play(profile_animations.current_animation) 
			
			if play_voice == true and voice_played <= parsed_text_length: # to make sure the sound doenst play when counting the bbcode text 
				voice_played += 1
				Character_Voice.play()
			
			play_voice = true
		if Debug_output:print(e)
		await get_tree().create_timer(Speed).timeout #every  0.05 seconds times the length of the text 
		
		if text_node.visible_characters >= parsed_text_length or Input.is_action_pressed("Skip_Text") and skipable: # if the text is skiped or all the parse text it shown
			text_node.visible_characters = text_node.text.length() # set the visable characters to the full length
			break # exit out of for loop
	
	if text_node.visible_characters == text_node.text.length(): # if all the text is showen.
		if Debug_output: print("finised")
		# if that 'Responses' doesnt exist it will return null
		if not current_diauogue_id  >= len(Dialogue[str(conversation_id)]) and Dialogue[str(conversation_id)][current_diauogue_id].get('Choices'):# when pressing the skip button to fast it crashesx
			if Debug_output: print(Dialogue[str(conversation_id)][current_diauogue_id]['Choices'])
			choices_exsist = true
			Choice_Responces = Dialogue[str(conversation_id)][current_diauogue_id]['Responses']
			Choice_Aftermath = Dialogue[str(conversation_id)][current_diauogue_id]['Aftermath']
			show_choices()
			
		is_dialogue_runing = false
		has_dialogue_ran = true
		
		# options
		if not reaction_text.text == "":
			if FileAccess.file_exists(Profile_path + str(Dialogue[str(conversation_id)][current_diauogue_id]['reactions'][0]) + " Profile.png"):
				react_profile.texture = load(Profile_path + str(Dialogue[str(conversation_id)][current_diauogue_id]['reactions'][0]) + " Profile.png")
			show_responce.play("slide in")
		if auto_skip: Next_Dialogue()
	

func show_choices():
	# variables
	var Choices:Array = Dialogue[str(conversation_id)][current_diauogue_id]['Choices']
	# reset options text
	for b in options.get_children():
		if b is Button:
			b.text = ""
	
	options.position = Vector2(200, 504) # default posioton
	if Character_Text.text == "" and Choices[2] == "" and Choices[3] == "":
		options.position = Vector2(200, 490)
	
	for b in options.get_children():
		var index = b.get_index()
		if b is Button:
			options.get_child(index).visible = false
			if not Choices[index] == "": # Make sure theres a reaction_text
				options.show()
				options.get_child(index).visible = true
				options.get_child(index).text = Choices[index]
				if Choices.size() == 1:
					options.get_child(0).grab_focus()
				if Debug_output: print(options.get_child(index).text)
				if Choice_Responces[index] != 0:
					options.get_child(index).pressed.connect(func():
						change_to_choice_dialouge(index)
						) 
				else: 
					if Debug_output: print("choice " + str(b.get_index()) + " exit")
					dialogue_finished.emit()
					return # to exit out the function
	

func _on_overlap_detection_body_entered(body: Node2D) -> void:
	if visible == false:
		dialogue_ui.position.y = -472

func _on_overlap_detection_body_exited(body: Node2D) -> void:
	if visible == false:
		dialogue_ui.position = Vector2.ZERO


func _on_overlap_detection_area_entered(area: Area2D) -> void:
	if  visible == false:
		dialogue_ui.position.y = -472

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
