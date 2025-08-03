extends Control

@export var dialoue_choices:bool
@export var scelect_icon: Node2D
@export var icon_offset: Vector2 = Vector2(10, -20)

func _ready() -> void: if not dialoue_choices: get_child(0).grab_focus()

func _process(_delta: float) -> void:
	if dialoue_choices == true and Diauloge_Systerm.choices_exsist == true and Diauloge_Systerm.Is_Dialogue_Runing == false:
		if get_child(0).text != '' and not get_child(0).has_focus() and Input.is_action_just_pressed("Left"):
			get_child(0).grab_focus()
		if get_child(1).text != '' and not get_child(1).has_focus() and Input.is_action_just_pressed("Right"):
			get_child(1).grab_focus()
		if get_child(2).text != '' and not get_child(2).has_focus() and Input.is_action_just_pressed("Up"):
			get_child(2).grab_focus()
		if get_child(3).text != '' and not get_child(3).has_focus() and Input.is_action_just_pressed("Down"):
			get_child(3).grab_focus()
	
	for B in get_children():
		if B is Button and B.has_focus():
			scelect_icon.position = B.position - icon_offset
	
