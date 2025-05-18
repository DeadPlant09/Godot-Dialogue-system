extends VisibleOnScreenNotifier2D
class_name Visible_On_Screen_handeler

@export var Delete_if_not_on_Screne:bool = false



func _ready() -> void:
	screen_exited.connect(func():
		if Delete_if_not_on_Screne == true:
			get_parent().queue_free()
		else:
			get_parent().hide()
		)
	screen_entered.connect(func():
		get_parent().show()
		
	)

