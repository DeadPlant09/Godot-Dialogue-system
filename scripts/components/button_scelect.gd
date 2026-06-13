extends Control

class_name Button_Select

@export var dialoue_choices:bool

@export var scelect_icon: Node2D

@export var icon_offset: Vector2 = Vector2(10, -20)


func _ready() -> void:
	if not dialoue_choices:
		get_child(0).grab_focus()


func _process(_delta: float) -> void:
	if not visible:
		return
	
	if dialoue_choices == true and Dialogue_System.choices_exsist == true and Dialogue_System.is_dialogue_runing == false:
		if choice_is_focused(0) and Input.is_action_just_pressed("Left"):
			get_child(0).grab_focus()
		
		elif choice_is_focused(1) and Input.is_action_just_pressed("Right"):
			get_child(1).grab_focus()
		
		elif choice_is_focused(2) and Input.is_action_just_pressed("Up"):
			get_child(2).grab_focus()
		
		elif choice_is_focused(3) and Input.is_action_just_pressed("Down"):
			get_child(3).grab_focus()
	
	
	for B in get_children():
		if B is Button and B.has_focus():
			scelect_icon.position = B.position - icon_offset


func choice_is_focused(button_index: int):
	return get_child(button_index).text != '' and not get_child(button_index).has_focus()
