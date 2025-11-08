extends Node2D
class_name NPC

# @export variables
@export var instances:Dictionary
@export var turn_off_animations: bool # used for nodes you just want to recive dialogue signals 
@export var dialogue_area:DialogueArea
@export var sprite_animation:AnimationPlayer
@export var talk_index = 0
@export_multiline var connect_signal:String: # for every signal in the variable connect to each of them
	set(new_value):
		connect_signal = new_value
		var dialogue_signals = Dialogue_System.get_signal_list()
		for S in dialogue_signals:
			if S["name"] in connect_signal and not Dialogue_System.is_connected(S["name"], Callable(self, S["name"])):
				if debug: print(S["name"])
				Dialogue_System.connect(S["name"], Callable(self, S["name"]))
@export var debug: bool

# variables
var save_data = Dialogue_System.Save_Data
var saved_instances = save_data["npc_instance"]
var saved_convos = save_data["conversations"]
var saved_choices = save_data["chocies"]


func _ready() -> void:
	if not instances.is_empty(): # if its set to move and can
		
		position = instances[instances.keys()[0]]
		
		for instance in instances: # check every instance
			var index = instances.keys().find(instance) # in the list of key find the instance and return the name
			if instance_has_passed(instance) and not index + 1 < instances.size(): # if this instance is has passed and there are no more instances: delete 
				if debug: print(str(index) + " delete")
				queue_free()
			
			if not instance_has_passed(instance): # if if theres an instance that hasnt passed
				saved_instances[name] = instance # set to current instance
				position = instances[instance] # set instance positon
				if debug: print(saved_instances[name])
				break # stop checking instances
	
	Dialogue_System.choice_was_made.connect(use_choice_instance)
	
	if not can_remember_convo(): return # if you chose remember the npc convo
	dialogue_area.starting_convo = saved_convos[name][0]
	dialogue_area.ending_convo = saved_convos[name][1]
	if debug: print("remembered_temp")


func instance_has_passed(instance: int):
	return saved_instances.has(name) and instance < saved_instances[name]

func can_remember_convo():
	return saved_convos.has(name) and saved_convos[name][0] >= dialogue_area.starting_convo and saved_convos[name][0] <= dialogue_area.ending_convo


func _process(_delta: float) -> void: if sprite_animation != null: npc_animations()

func use_choice_instance():
	if not saved_choices.has(name):return
	if not saved_choices[name].has(Dialogue_System.choice_convo):return
	
	print("choice convo " + str(saved_choices[name][Dialogue_System.choice_convo]))
	
	saved_instances[name] = saved_choices[name][Dialogue_System.choice_convo]
	dialogue_area.chose_convo()
	
	await Dialogue_System.dialogue_finished
	
	dialogue_area.set_current_dialogue()


func npc_animations():
	if turn_off_animations: return
	
	if dialogue_area.detect_player and name in Dialogue_System.Sprites.get_child(2).text: # if the npc is talking
		if Dialogue_System.Is_Dialogue_Runing: # if the npc is currently talking
			sprite_animation.play("Talk" + str(talk_index))
		else: # if the npc is finsished talking
			sprite_animation.pause()
			sprite_animation.play("Talk" + str(talk_index))
	
	else: # if the npc isnt talking
		sprite_animation.get_animation(sprite_animation.name + str(talk_index)).loop_mode = Animation.LOOP_LINEAR
		sprite_animation.play(sprite_animation.name + str(talk_index))


func run_signal_actions(action: String): # to run a signal action without runing a signal
	connect_signal = action 
	call(action)

func update_godot_dialogue():
	saved_instances[name] = 1 # set current_instance to instance 1
	dialogue_area.chose_convo() # set convo to current_instance
	if Dialogue_System.wait_for_signal: Dialogue_System.signal_wait_finshed.emit()
