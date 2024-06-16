extends CharacterBody3D
class_name Player

#Public variables
@export var MovementSpeed : float
@export var MouseSensitivity : float
@export var StickSensitivity : float
@export var DashSpeedOverTime : Curve
@export var DashTime: float 
#@export var DashCooldown : float
@export var PickUpRange : float
@export var MaxOxygenTime : float
@export var DepleteOxygen : bool = true

#Private variables
var isDashing : bool = false
var dashTimeElapsed : float = 0
var currentSpeed : float
var currentOxygen : float
var sceneRoot

#Components
@onready var cam = $Camera3D
@onready var raycastFromCam = $Camera3D/RayCast3D
@onready var rightHand = $"Camera3D/Right Hand"
@onready var leftHand = $"Camera3D/Left Hand"
@onready var middleHand = $"Camera3D/Secret Third Hand"
@onready var oxygenBar = $Control/Panel/CenterContainer/ProgressBar as ProgressBar
@onready var decoyLeft = $"Camera3D/Decoy Item" as Node3D
@onready var decoyRight = $"Camera3D/Decoy Item2" as Node3D

@onready var viginette_shader := $"CanvasLayer/Viginette"
@onready var pixilate_shader := $"CanvasLayer/Pixilate"

static var I : Player

#AudioStreams
@onready var ambient_background := $"AmbientPlayer"
@onready var swim_player := $"SwimPlayer"
@onready var drown_player := $"DrownPlayer"

var is_dead : bool

func _init():
	I = self

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	currentSpeed = MovementSpeed
	currentOxygen = MaxOxygenTime
	oxygenBar.max_value = MaxOxygenTime
	
	sceneRoot = get_parent()
	
	ambient_background.play()
	
	spawn()
	

func _physics_process(delta):
	#Handle movement
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
	var verticalInput = Input.get_axis("Swim Down", "Swim Up")
	
	var dir_vector = (input_dir.y * cam.global_transform.basis.z) + (input_dir.x * global_transform.basis.x)
	var desired_velocity = currentSpeed * dir_vector + Vector3(0, verticalInput, 0)
	
	if input_dir != Vector2():
		velocity = lerp(velocity, desired_velocity, 0.1)
	else:
		velocity *= .97
		
	move_and_slide()
	
	if input_dir != Vector2() && !swim_player.playing:
		swim_player.play()
	
func _process(delta):
	if(DepleteOxygen):
		ChangeOxygen(-delta)
	
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
		
	if Input.is_action_just_released("ItemUse_Left"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		CancelItem(leftHand)
		
	if Input.is_action_just_released("ItemUse_Right"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		CancelItem(rightHand)
	
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
	if(item.name.contains("Decoy")):
		item = middleHand.get_child(0)
		decoyLeft.get_parent().remove_child(decoyLeft)
		cam.add_child(decoyLeft)
		decoyRight.get_parent().remove_child(decoyRight)
		cam.add_child(decoyRight)

	item.get_parent().remove_child(item)
	sceneRoot.add_child(item)
	item.transform = itemTransfromValues
	item.get_child(0).OnItemReleased()
	

func TryGetItem(hand):
	var collider = raycastFromCam.get_collider() as Node3D
	
	if collider != null:
		if collider.is_in_group("Interactable"):
			collider.interact(hand)
			return
			
		if(collider.is_in_group("Item")):
			if(collider.name.contains("Chest")):
				TryGetChest(collider)
				return
			
			collider.get_parent().remove_child(collider)
			hand.add_child(collider)
			collider.position = Vector3.ZERO
			collider.rotation_degrees = Vector3.ZERO
			collider.scale = Vector3.ONE
			
			collider.get_child(0).OnItemGrabbed()

func TryGetChest(chest):
	if(CheckHandStatus(rightHand) != null || CheckHandStatus(leftHand) != null):
		return
	
	cam.remove_child(decoyLeft)
	leftHand.add_child(decoyLeft)
	cam.remove_child(decoyRight)
	rightHand.add_child(decoyRight)
	
	chest.get_parent().remove_child(chest)
	middleHand.add_child(chest)
	chest.position = Vector3.ZERO
	chest.rotation_degrees = Vector3.ZERO
	chest.scale = Vector3.ONE
	chest.get_child(0).OnItemGrabbed()

func LetChestGo():
	leftHand.remove_child(decoyLeft)
	cam.add_child(decoyLeft)
	rightHand.remove_child(decoyRight)
	cam.add_child(decoyRight)
	middleHand.remove_child(middleHand.get_child(0))

func UseItem(hand):
	var item = CheckHandStatus(hand)
	
	if(item != null):
		item.OnItemUse()
		
func CancelItem(hand):
	var item = CheckHandStatus(hand)
	if(item != null):
		item.OnCancelUse()
	

func CheckHandsForItem(itemName) -> Node3D:
	var desiredItem : Node3D = null
	var leftItem = CheckHandStatus(leftHand)
	var rightItem = CheckHandStatus(rightHand)
	
	if leftItem != null && leftItem.name.contains(itemName):
		desiredItem = leftItem
	if rightItem != null && rightItem.name.contains(itemName):
		desiredItem = rightItem
	return desiredItem
	
func ChangeOxygen(amount):
	currentOxygen += amount
	currentOxygen = clamp(currentOxygen, 0, MaxOxygenTime)
	oxygenBar.value = currentOxygen
	
	if(currentOxygen <= 0) && !is_dead:
		GameOver()
		return

func GameOver():
	is_dead = true
	
	viginette_shader.visible = true
	pixilate_shader.visible = true
	create_tween().tween_method(func(value): viginette_shader.material.set_shader_parameter("SCALE", value), 1.3, 0, 0.5)
	create_tween().tween_method(func(value): pixilate_shader.material.set_shader_parameter("amount", value), 200, 30, 0.2)
	
	drown_player.play()
	
	await get_tree().create_timer(1.5).timeout
	reset_game()

func spawn():
	is_dead = false
	viginette_shader.visible = true
	pixilate_shader.visible = true

	create_tween().tween_method(func(value): viginette_shader.material.set_shader_parameter("SCALE", value), 0, 1.3, 1)
	create_tween().tween_method(func(value): pixilate_shader.material.set_shader_parameter("amount", value), 30, 200, 1)
	await get_tree().create_timer(1).timeout
	
	viginette_shader.visible = false
	pixilate_shader.visible = false

func reset_game():
	get_tree().reload_current_scene()
