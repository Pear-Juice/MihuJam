extends CharacterBody3D
class_name Player

#Public variables
@export var MovementSpeed : float
@export var MouseSensitivity : float
@export var StickSensitivity : float
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


func _init():
	I = self

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	currentSpeed = MovementSpeed

func _physics_process(delta):
	#Handle movement
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
	velocity = (input_dir.y * cam.global_transform.basis.z) + (input_dir.x * global_transform.basis.x)
	var vecticalInput = Input.get_axis("Swim Down", "Swim Up")
	velocity.y += vecticalInput
	velocity *= currentSpeed

	move_and_slide()
	
func _process(delta):
	if isDashing:
		currentSpeed = DashSpeedOverTime.sample(dashTimeElapsed/DashTime)
		dashTimeElapsed += delta
		
		if dashTimeElapsed >= DashTime:
			EndDash()
			
	if Input.is_action_just_pressed("Pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if Input.is_action_just_pressed("Dash") && !isDashing:
		StartDash()
	
	if Input.is_action_just_pressed("ItemUse_Left"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		UseItem(leftHand)
		
	if Input.is_action_just_pressed("ItemUse_Right"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		UseItem(rightHand)
	
	if(Input.is_action_just_pressed("ItemGrab_Left")):
		if(CheckHandStatus(leftHand)):
			LetItemGo(CheckHandStatus(leftHand))
		else:
			TryGetItem(leftHand)
			
	if(Input.is_action_just_pressed("ItemGrab_Right")):
		if(CheckHandStatus(rightHand)):
			LetItemGo(CheckHandStatus(rightHand))
		else:
			TryGetItem(rightHand)
			
	cam.rotate_x(Input.get_axis("Camera Down", "Camera Up") * StickSensitivity)
	if abs(cam.rotation_degrees.y) < 1:
		rotate_y(-Input.get_axis("Camera Left", "Camera Right") * StickSensitivity)
	else:
		rotate_y(-Input.get_axis("Camera Left", "Camera Right") * StickSensitivity)

#Handle camera movement with mouse
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		cam.rotate_x(-event.relative.y * MouseSensitivity)
		if abs(cam.rotation_degrees.y) < 1:
			rotate_y(-event.relative.x * MouseSensitivity)
		else:
			rotate_y(event.relative.x * MouseSensitivity)

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
	item.get_child(0).OnItemReleased()
	

func TryGetItem(hand):
	var item = raycastFromCam.get_collider() as Node3D
	
	if item != null:
		if(!item.is_in_group("Item")):
			return
		
		item.get_parent().remove_child(item)
		hand.add_child(item)
		item.position = Vector3.ZERO
		item.rotation_degrees = Vector3.ZERO
		item.scale = Vector3.ONE
		
		item.get_child(0).OnItemGrabbed()
		
func UseItem(hand):
	var item = CheckHandStatus(hand)
	
	if(item != null):
		item.OnItemUse()
