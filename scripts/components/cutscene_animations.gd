extends AnimationPlayer

class_name Cutscene_animation

@export var connect_signal:Array:
	set(new_value):
		connect_signal = new_value
		
		for S in connect_signal:
			if not Dialogue_System.is_connected(S, play_animation.bind(S)):
				
				Dialogue_System.connect(S, play_animation.bind(S))

@export var only_in_cutscene:bool


func play_animation(animaiton_name:String):
	# to prevent these runing when the signals are from NPCs not the cutscene
	if only_in_cutscene and not Dialogue_System.in_cutscene:
		return
	
	play(animaiton_name)
	
	# you remove player input if your singal is "dialogue_finished"
	Dialogue_System.remove_player_input()
	
	await animation_finished
	 
	Dialogue_System.add_player_input()
	
	Dialogue_System.signal_wait_finished.emit()
