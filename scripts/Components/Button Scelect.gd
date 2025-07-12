extends Control

@export var dialoue_choices:bool
@export var scelect_icon: Node2D
@export var icon_offset: Vector2 = Vector2(10, -25)
@export var button_0: Button
@export var button_1: Button
@export var button_2: Button
@export var button_3: Button
@export var button_4: Button
@export var button_5: Button
@export var button_6: Button
@export var button_7: Button

func _process(_delta: float) -> void:
	if dialoue_choices == true:
		if Diauloge_Systerm.choices_exsist == true and Diauloge_Systerm.has_dialogue_ran == true: # fix this moving when a character without chocies is speaking?
			if button_0.text != '' and not button_0.has_focus() and Input.is_action_just_pressed("Left"):
				button_0.grab_focus()
			if button_1.text != '' and not button_1.has_focus() and Input.is_action_just_pressed("Right"):
				button_1.grab_focus()
			if button_2.text != '' and not button_2.has_focus() and Input.is_action_just_pressed("Up"):
				button_2.grab_focus()
			if button_3.text != '' and not button_3.has_focus() and Input.is_action_just_pressed("Down"):
				button_3.grab_focus()
	else: button_0.grab_focus()
	
	if button_0 != null and button_0.has_focus():
		scelect_icon.position = button_0.position - icon_offset
	if button_1 != null and button_1.has_focus():
		scelect_icon.position = button_1.position - icon_offset
	if button_2 != null and button_2.has_focus():
		scelect_icon.position = button_2.position - icon_offset
	if button_3 != null and button_3.has_focus():
		scelect_icon.position = button_3.position - icon_offset
	if button_4 != null and button_4.has_focus():
		scelect_icon.position = button_4.position - icon_offset
	if button_5 != null and button_5.has_focus():
		scelect_icon.position = button_5.position - icon_offset
		
