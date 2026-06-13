extends Control

class_name Button_Select

@export var dialoue_choice:bool

@export var scelect_icon: Node2D

@export var icon_offset: Vector2 = Vector2(10, -20)


func _ready() -> void:
	if not dialoue_choice:
		get_child(0).grab_focus()
	else:
		Dialogue_System.dialogue_finished.connect(reset_icon)


func _input(_event: InputEvent) -> void:
	if not visible:
		return
	
	if dialoue_choice == true and Dialogue_System.choices_exsist == true and Dialogue_System.is_dialogue_runing == false:
		if choice_is_not_focused(0) and Input.is_action_just_pressed("Left"):
			get_child(0).grab_focus()
		
		elif choice_is_not_focused(1) and Input.is_action_just_pressed("Right"):
			get_child(1).grab_focus()
		
		elif choice_is_not_focused(2) and Input.is_action_just_pressed("Up"):
			get_child(2).grab_focus()
		
		elif choice_is_not_focused(3) and Input.is_action_just_pressed("Down"):
			get_child(3).grab_focus()
	
	
	for B in get_children():
		if B is Button and B.has_focus():
			scelect_icon.position = B.position - icon_offset


func reset_icon():
	scelect_icon.position = Vector2(376.0, 72.0)


func choice_is_not_focused(button_index: int):
	return get_child(button_index).text != '' and not get_child(button_index).has_focus()
