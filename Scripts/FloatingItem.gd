extends Node3D

@export var FloatTime : float
@export var FallingSpeed : float

@onready var omniLight = $"../Item Light" as OmniLight3D

var body
var timeElapsed : float = 0
var held : bool = false
var isFalling : bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	body = get_parent() as CharacterBody3D
	if(get_parent().get_parent().name.contains("Hand")):
		OnItemGrabbed()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !held && !isFalling:
		timeElapsed += delta
		if timeElapsed > FloatTime:
			body.velocity.y = FallingSpeed
			isFalling = true
			

func _physics_process(delta):
	if(!held):
		if(!isFalling):
			body.velocity.y = sin(timeElapsed ) * .15
		body.move_and_slide()
			
	

func OnItemGrabbed():
	held = true
	isFalling = false
	timeElapsed = 0
	omniLight.visible = false

func OnItemReleased():
	held = false
	timeElapsed = 0
	omniLight.visible = true
