extends CharacterBody2D
class_name Player


@export var SPEED:int = 10

# Node variables
@onready var Animations = $AnimationPlayer
@onready var image = $Image
# Movement
func _physics_process(_delta):
	if Diauloge_Systerm.Deactivated == true and not Diauloge_Systerm.can_move: 
		SPEED = 0
	else: 
		SPEED = 10
		player() # player movement
		animations()
	
func player():
	var imput_vector = Vector2.ZERO
	
	imput_vector.x = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	imput_vector.y = Input.get_action_strength("Down") - Input.get_action_strength("Up")
	imput_vector.normalized()
	
	
	if imput_vector:
		velocity = imput_vector * SPEED
	else:
		velocity = imput_vector
	move_and_collide(velocity)

func animations():
	if Input.is_action_pressed("Right") or Input.is_action_pressed("Down"):
		Animations.play("Run right")
		
	elif Input.is_action_pressed("Left") or Input.is_action_pressed("Up"):
			Animations.play("Run left")
		
	else:
			Animations.play("Idle")
