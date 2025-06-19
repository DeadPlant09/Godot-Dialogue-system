class_name dialoguesystemnode extends CanvasLayer

# signal
signal dialogue_finished
#node variables
@onready var dialogue_ui = $"Dialogue UI"
@onready var sprites: Control = $"Dialogue UI/Sprites"
@onready var overlap_detection: Area2D = $"Overlap Detection"
@onready var Character_Text = $"Dialogue UI/RichTextLabel"
@onready var Character_Icon = %Icon
@onready var Character_Voice: AudioStreamPlayer2D = $"Dialogue UI/Voice"
@onready var options = $"Dialogue UI/Options"
@onready var Reaction: RichTextLabel = $"Dialogue UI/Response"
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
@export var Icon_path = "res://Sprites/Character's/"
@export var Voice_path = "res://Audio/"
# option variables
@export var Debug_output:bool 
var In_Cutscene = false
var default_volume_db = 0.0
var skipable = true 
var play_voice = true
var auto_skip = false
var wait_for_chocies = false
var pause_at_ending_of_sentence = true
var silent_characters = ["!",",", "-", ".", "?",";", '"', "©", "™", "[", "]"]
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
	Set_Profile(Character_Icon)
	set_text()

func Set_Profile(image_node: TextureRect):
	Character_Text.visible_ratio = 0 # when you change your character profile reste the visable text to 0
	# reset the postion and size to defaults 
	Character_Text.position.x = 320
	Character_Text.size.x = 608
	Character_Voice.stream = load(Voice_path + "Default dialogue voice.wav")
	
	if FileAccess.file_exists(Voice_path + str(Dialogue[str(conversation_id)][current_diauogue_id]['Name']) + " voice.wav"):
		Character_Voice.stream = load(Voice_path + str(Dialogue[str(conversation_id)][current_diauogue_id]['Name']) + " voice.wav")
	
	if FileAccess.file_exists(Icon_path + str(Dialogue[str(conversation_id)][current_diauogue_id]['Name']) + ".svg"):
		image_node.texture = load(Icon_path + str(Dialogue[str(conversation_id)][current_diauogue_id]['Name']) + ".svg")
	elif FileAccess.file_exists(Icon_path + str(Dialogue[str(conversation_id)][current_diauogue_id]['Name']) + ".png"):
		image_node.texture = load(Icon_path + str(Dialogue[str(conversation_id)][current_diauogue_id]['Name']) + ".png")
	else:
		image_node.texture = null 
		Character_Text.position.x = 208
		Character_Text.size.x = 720

func set_text():
	if Dialogue[str(conversation_id)][current_diauogue_id].get('Screen position', []):# if that 'Screen_position' doesnt exist it will return null
		dialogue_ui.position.x = Dialogue[str(conversation_id)][current_diauogue_id]['Screen position'][0]
		dialogue_ui.position.y = Dialogue[str(conversation_id)][current_diauogue_id]['Screen position'][1]
	
		
	Character_Text.text = Dialogue[str(conversation_id)][current_diauogue_id]['Text'] 
	
	if not Dialogue[str(conversation_id)][current_diauogue_id].get('Speed'):
		scrolling_text(Character_Text) 
	else:
		scrolling_text(Character_Text, Dialogue[str(conversation_id)][current_diauogue_id]['Speed']) # make the charcter text scroll after you set it
	


func scrolling_text(text_node:RichTextLabel, Speed = 0.05):
	var voice_played = 0
	var parsed_text_length = text_node.get_parsed_text().length()
	for e in text_node.get_text(): # scroling text, for every letter in character text
		text_node.visible_characters += 1 # make one character visable
		if is_dialogue_runing:
			set_up_dialogue_options()
			if not text_node.visible_characters == 0 and e == ","  or e == "-" or e == ";" or e == ":": # Small pasues at beginging or middle of sentece
				# if the character is these letter wait a little more
				await get_tree().create_timer(0.1).timeout
			
			if pause_at_ending_of_sentence and e == "." or e == "?" or e == "!": # Long pasues at the End of sentece
				# if the character is these letter wait a little more
				await get_tree().create_timer(0.3).timeout
			
			for c in silent_characters:
				if e == c: play_voice = false
			
			if play_voice == true and voice_played <= parsed_text_length: # to make sure the sound doenst play when counting the bbcode text 
				voice_played += 1
				Character_Voice.play()
			
		await get_tree().create_timer(Speed).timeout #every  0.05 seconds times the length of the text 
		
		if text_node.visible_characters >= parsed_text_length or Input.is_action_pressed("Skip_Text") and skipable: # if the skip text input was pressed
			text_node.visible_characters = text_node.text.length() # set the visable characters to the full length
			break
	
	if text_node.visible_characters == text_node.text.length() or text_node.visible_characters == parsed_text_length: # if all the parsed text is showen.
		# if that 'Responses' doesnt exist it will return null
		if not current_diauogue_id  >= len(Dialogue[str(conversation_id)]) and Dialogue[str(conversation_id)][current_diauogue_id].get('Choices'):# when pressing the skip button to fast it crashesx
			if Debug_output: (Dialogue[str(conversation_id)][current_diauogue_id]['Choices'])
			choices_exsist = true
			Choice_Responces = Dialogue[str(conversation_id)][current_diauogue_id]['Responses']
			Choice_Aftermath = Dialogue[str(conversation_id)][current_diauogue_id]['Aftermath']
			show_choices()
			
		is_dialogue_runing = false
		has_dialogue_ran = true
		# options
		if not Reaction.text == "": show_responce.play("slide in")
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
			if not Choices[index] == "": # Make sure theres a Reaction
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

func set_up_dialogue_options():
	Character_Voice.volume_db = Dialogue[str(conversation_id)][current_diauogue_id].get('volume', 0.0)
	skipable = Dialogue[str(conversation_id)][current_diauogue_id].get('skipable', true)
	play_voice = Dialogue[str(conversation_id)][current_diauogue_id].get('voice', true)
	auto_skip = Dialogue[str(conversation_id)][current_diauogue_id].get('Auto Skip', false)
	wait_for_chocies = Dialogue[str(conversation_id)][current_diauogue_id].get('Choices')
	pause_at_ending_of_sentence =  Dialogue[str(conversation_id)][current_diauogue_id].get('pause at ending', true)
	just_show_text = Dialogue[str(conversation_id)][current_diauogue_id].get('just text', false)
	Reaction.text =  Dialogue[str(conversation_id)][current_diauogue_id].get('reactions', "")
