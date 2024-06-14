class_name Player

extends CharacterBody3D

@export var MovementSpeed : float
@export var CameraSensitivity : float

@onready var cam = $Camera3D
#const JUMP_VELOCITY = 4.5

static var I : Player

func _init():
	I = self

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * CameraSensitivity)
		cam.rotate_x(-event.relative.y * CameraSensitivity)

func _physics_process(delta):
	#Handle movement
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
	velocity = (input_dir.y * cam.global_transform.basis.z) + (input_dir.x * global_transform.basis.x)
	velocity *= MovementSpeed

	move_and_slide()
