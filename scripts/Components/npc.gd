extends Node2D

class_name NPC

# @export variables
@export var instances:Dictionary = {0:""}

# used for nodes you just want to recive dialogue signals
@export var turn_off_animations:bool
 
@export var dialogue_area:DialogueArea

@export var sprite_animation:AnimationPlayer

# for every signal in the variable connect to each of them
@export var connect_signal:Array:
	set(new_value):
		connect_signal = new_value
		
		for S in connect_signal:
			if not Dialogue_System.is_connected(S, Callable(self, S)):
				
				Dialogue_System.connect(S, Callable(self, S))

# variables
var save_data = Dialogue_System.save_data

var saved_instances = save_data["npc_instance"]

var saved_convos = save_data["conversations"]

var saved_choices = save_data["choices"]


func _ready() -> void:
	check_available_instances()
	
	Dialogue_System.choice_was_made.connect(use_choice_aftermath_as_instance)
	
	# if you chose remember the npc convo
	if not can_remember_convo():
		return
	
	dialogue_area.set_instance_to_current_convo()


func _process(_delta: float) -> void:
	if sprite_animation == null:
		return
	
	npc_animations()


func check_available_instances():
	# if the instance set to move and can
	if instances.is_empty():
		return
	
	 # check every instance
	for instance in instances:
		
		# in the list of key find the instance and return the name
		var index = instances.keys().find(instance)
		var instance_choice = instances[instance]
		
		# if theres an instance that hasn't passed and that instance is available
		if not instance_has_passed(instance) and instance_is_available(instance_choice):
			
			# set to current instance
			saved_instances[name] = instance 
			
			# stop checking for other instances
			break
		
		# if this instance is has passed and there are no more instances: delete 
		elif check_for_last_instance(index):
			queue_free()


func use_choice_aftermath_as_instance():
	# make sure your the current npc in the convo and that your instance has been saved
	if not Dialogue_System.current_npc == name or not saved_instances.has(name):
		return
	
	dialogue_area.chose_current_npc_instance()
	
	await Dialogue_System.dialogue_finished
	
	dialogue_area.set_current_dialogue()


func npc_animations():
	if turn_off_animations:
		return
	
	# if the npc is the profile
	if Dialogue_System.deactivated and name in Dialogue_System.character_name.text:
		# if the npc is currently talking
		if Dialogue_System.is_dialogue_runing:
			sprite_animation.get_animation("Talk").loop_mode = Animation.LOOP_LINEAR
			
			sprite_animation.play("Talk")
		
		# if the npc is finsished talking
		else:
			sprite_animation.get_animation("Talk").loop_mode = Animation.LOOP_NONE
	
	# if the npc isnt talking
	else:
		sprite_animation.get_animation(sprite_animation.name).loop_mode = Animation.LOOP_LINEAR
		
		sprite_animation.play(sprite_animation.name)


func run_signal_actions(action: String):
	# to run a signal action without runing a signal
	call(action)


func sure_the_earth_is_flat():
	# set current npc instance to instance 1 and set current_convo to current_instance
	saved_instances[name] = 1
	
	# make the npc instance the current instance
	dialogue_area.chose_current_npc_instance()
	signal_function_finished()


func your_crazy():
	saved_instances[name] = 2
	
	dialogue_area.chose_current_npc_instance()
	signal_function_finished()


func leave_scene_right():
	# play animation
	pass


func leave_scene_left():
	# play animation
	pass


func signal_function_finished():
	if Dialogue_System.wait_for_signal:
		Dialogue_System.signal_wait_finished.emit()


func instance_has_passed(instance: int):
	# if your instance has been added and the current instance is less than it.
	return saved_instances.has(name) and instance < saved_instances[name]


func instance_is_available(instance_choice: String):
	if instance_choice == "":
		return true
	
	for choice in saved_choices:
		if instance_choice == choice:
			return true
	
	return false


func check_for_last_instance(instance_index: int):
	return instance_index + 1 >= instances.size()


func can_remember_convo():
	return saved_convos.has(name) and saved_convos[name][0] >= dialogue_area.starting_convo and saved_convos[name][0] <= dialogue_area.ending_convo
