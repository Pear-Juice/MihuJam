extends Node3D

@export var search_color : Color
@export var lock_color : Color
@export var lock_head_rot_speed_mod : float

@onready var target = $"Model/Armature/Skeleton3D/Target"
@onready var skeleton : Skeleton3D = $"Model/Armature/Skeleton3D"
@onready var animator := $"Model/AnimationPlayer"
var head_bone : int
var last_head_bone_transform : Transform3D

var player_in_sight : bool
var pull_force : float

@onready var tongue := $"Tongue"
@onready var test_cube := $"TestCube"

var state_m : StateMachine

func _ready():
	%Tongue/Light.light_color = search_color
	animator.play("Search")
	head_bone = skeleton.find_bone("Head")
	
	state_m = StateMachine.create(self)
	state_m.add_state("Searching", searching_start, searching_run)
	state_m.add_state("Lock", lock_start, lock_run)
	state_m.add_state("Lost", lost_start)
	state_m.debug = true
	
	state_m.transfer("Searching")

func searching_start():
	animator.play()
	%Tongue/Light.light_color = search_color
	
func searching_run(delta):
	var head_bone_transform : Transform3D = skeleton.global_transform * skeleton.get_bone_global_pose(head_bone)
	tongue.global_transform = head_bone_transform
	
	if player_in_sight:
		last_head_bone_transform = head_bone_transform
		state_m.transfer("Pull")

func lock_start():
	%Tongue/Light.light_color = lock_color
	animator.pause()
	
func lock_run(delta):
	var head_bone_transform : Transform3D = skeleton.global_transform * skeleton.get_bone_global_pose(head_bone)
	#create new basis relative to head bones basis and rotate it towards the player
	var desired_basis : Basis = head_bone_transform.looking_at(Player.I.global_position, Vector3.UP).basis
	desired_basis = desired_basis * Basis(Vector3(1,0,0),Vector3(0,0,-1),Vector3(0,1,0))
	desired_basis = head_bone_transform.basis.orthonormalized().slerp(desired_basis.orthonormalized(), delta * lock_head_rot_speed_mod)
	var new_transform = Transform3D(desired_basis, head_bone_transform.origin)
	
	#set transforms of head bone and tongue
	skeleton.set_bone_global_pose_override(head_bone, skeleton.global_transform.affine_inverse() * new_transform, 1.0, false)
	tongue.global_transform = new_transform
	
	if !player_in_sight && state_m.current_state.elapsed_time > 1:
		state_m.transfer("Lost")
		return
		
	
		
	#if state_m.current_state.elapsed_time > 
		
func lost_start():
	var head_bone_transform : Transform3D = skeleton.global_transform * skeleton.get_bone_global_pose(head_bone)
	var tween = get_tree().create_tween() as Tween
	
	var set_head_bone_pos = func(pos):
		skeleton.set_bone_global_pose_override(head_bone, skeleton.global_transform.affine_inverse() * pos, 1, false)
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(set_head_bone_pos, head_bone_transform, last_head_bone_transform, 1.5)
	await tween.finished
	state_m.transfer("Searching")
	
func _on_sight_body_entered(body):
	if body is Player:
		player_in_sight = true

func _on_sight_body_exited(body):
	if body is Player:
		player_in_sight = false
		
func rotation_to(transform_1 :  Transform3D, target : Vector3):
	return transform_1.looking_at(target, Vector3.UP).basis.get_rotation_quaternion()
