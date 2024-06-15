extends Node3D

@export var FloatTime : float
@export var FallingSpeed : float

var body
var timeElapsed : float = 0
var held : bool = false
var isFalling : bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	body = get_parent()
	print(get_parent().name)
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
	if(isFalling):
		body.move_and_slide()
	

func OnItemGrabbed():
	held = true
	isFalling = false
	timeElapsed = 0

func OnItemReleased():
	held = false
	timeElapsed = 0
