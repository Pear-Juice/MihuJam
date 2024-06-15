extends CharacterBody3D
class_name Player

#Public variables
@export var MovementSpeed : float
@export var CameraSensitivity : float
@export var DashSpeedOverTime : Curve
@export var DashTime: float 
@export var DashCooldown : float
@export var PickUpRange : float

#Private variables
var isDashing : bool = false
var dashTimeElapsed : float = 0
var currentSpeed : float

#Components
@onready var cam = $Camera3D
@onready var raycastFromCam = $Camera3D/RayCast3D
@onready var rightHand = $"Camera3D/Right Hand"
@onready var leftHand = $"Camera3D/Left Hand"
static var I : Player

#Signals
signal itemGrabbed
signal itemReleased

func _init():
	I = self

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	currentSpeed = MovementSpeed

func _physics_process(delta):
	#Handle movement
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
	velocity = (input_dir.y * cam.global_transform.basis.z) + (input_dir.x * global_transform.basis.x)
	velocity *= currentSpeed

	move_and_slide()
	
func _process(delta):
	if isDashing:
		currentSpeed = DashSpeedOverTime.sample(dashTimeElapsed/DashTime)
		dashTimeElapsed += delta
		
		if dashTimeElapsed >= DashTime:
			EndDash()
	
func _input(event):
	if event.is_action_pressed("Pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if event.is_action_pressed("Dash") && !isDashing:
		StartDash()
	
	if event.is_action_pressed("ItemUse_Left"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if(event.is_action_pressed("ItemGrab_Left")):
		if(CheckHandStatus(leftHand)):
			LetItemGo(CheckHandStatus(leftHand))
		else:
			TryGetItem(leftHand)
			
	if(event.is_action_pressed("ItemGrab_Right")):
		if(CheckHandStatus(rightHand)):
			LetItemGo(CheckHandStatus(rightHand))
		else:
			TryGetItem(rightHand)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		cam.rotate_x(-event.relative.y * CameraSensitivity)
		if abs(cam.rotation_degrees.y) < 1:
			rotate_y(-event.relative.x * CameraSensitivity)
		else:
			rotate_y(event.relative.x * CameraSensitivity)

func StartDash():
	isDashing = true
	dashTimeElapsed = 0

func EndDash():
	isDashing = false
	currentSpeed = MovementSpeed

func CheckHandStatus(hand) -> Node3D:
	var itemInHand = null
	for child in hand.get_children():
		if(child.is_in_group("Item")):
			itemInHand = child
	return itemInHand

func LetItemGo(item):
	var itemTransfromValues = item.global_transform
	item.get_parent().remove_child(item)
	get_tree().root.add_child(item)
	item.transform = itemTransfromValues
	emit_signal("itemReleased")
	

func TryGetItem(hand):
	var item = raycastFromCam.get_collider()
	
	if item != null:
		if(!item.is_in_group("Item")):
			return
		
		get_tree().root.remove_child(item)
		hand.add_child(item)
		item.position = Vector3.ZERO
		item.rotation_degrees = Vector3.ZERO
		item.scale = Vector3.ONE
		
		emit_signal("itemGrabbed")
