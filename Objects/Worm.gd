class_name Worm

extends CharacterBody3D

@export var min_retarget_dist : float

@export var patrol_speed : float

@export var chase_speed : float
@export var run_speed : float
var current_speed : float

var is_targeting : bool
var target : Vector3
var lerp_target : Vector3
var state_m : StateMachine

var lerp_multiplier = 3.5

var aware_of_player : bool
var aware_length : float
var player_in_sight : bool

var health = 3

@export var aware_length_threshold : float

@export var wiggle_curve : Curve
@export var wiggle_amp : float
@export var wiggle_speed : int

var path : Path3D
var path_follower : PathFollow3D

@export var give_up_timelimit : int

func _ready():
	if find_child("Path3D"):
		path = find_child("Path3D")
	else:
		print("Err: no path specified")
		return
		
	if find_child("PathFollow3D"):
		path_follower = find_child("PathFollow3D")
	else:
		print("Err: no path follower specified")
		return
		
	state_m = StateMachine.create(self)
	
	state_m.add_state("Patrol", patrol_state, patrol_state_run)
	state_m.add_state("Chase", chase_state, chase_state_run)
	state_m.add_state("Run", run_state, run_state_run)
	state_m.add_state("Eat", eat_state)
	
	#state_m.debug = true
	
	spawn()
	
func spawn():
	target = get_next_target_loc()
	is_targeting = true
	global_position = target
	
	state_m.transfer("Patrol")
	
func _physics_process(delta):
	if is_targeting:
		lerp_target = lerp_target.slerp(target, delta * lerp_multiplier)
		$Target.global_position = lerp_target
		
		if global_position.distance_to(Player.I.global_position) > 2:
			look_at(lerp_target)
		velocity = global_position.direction_to(target) * current_speed
		
		move_and_slide()

func patrol_state():
	current_speed = patrol_speed
	
func patrol_state_run(delta):
	if aware_of_player:
		if aware_length > aware_length_threshold && !Cage.I.player_is_safe:
			state_m.transfer("Chase")
		aware_length += delta
	
	if global_position.distance_to(target) < min_retarget_dist:
		target = get_next_target_loc()

func get_next_target_loc(offset := 0):
	path_follower.progress += 5 + offset
	print(offset)
	var pos = path_follower.global_position
	return pos

func chase_state():
	current_speed = chase_speed
	
func chase_state_run(delta):
	target = Player.I.global_position
	
	if Cage.I.player_is_safe:
		player_escaped()
		
	if state_m.current_state.elapsed_time > give_up_timelimit:
		player_escaped()

func eat_state():
	is_targeting = false
	
	get_tree().create_tween().tween_property(self, "global_position", Player.I.global_position, 0.2)
	%EatPlayer.play()
	Player.I.GameOver()
	
func ram_state():
	current_speed = chase_speed
	state_m.transfer("Circle")
	
func run_state():
	current_speed = run_speed
	
	target = get_next_target_loc(30)
	
func run_state_run(delta):
	if global_position.distance_to(target) < min_retarget_dist:
		state_m.transfer("Patrol")

func _on_sight_entered(body):
	if body is Player  && !Cage.I.player_is_safe:
		player_in_sight = true
		state_m.transfer("Chase")
		
func _on_sight_body_exited(body):
	if body is Player:
		player_in_sight = false

func _on_eat_body_entered(body):
	if body is Player:
		state_m.transfer("Eat")
		
func player_escaped():
	target = get_next_target_loc()
	state_m.transfer("Patrol")
	
func kill():
	get_tree().create_tween().tween_method(func(value): rotation_degrees.z = value, 0, 180, 0.5)
	process_mode = Node.PROCESS_MODE_DISABLED
	
func bonk():
	if health > 1:
		aware_length = 0
		aware_of_player = false
		state_m.transfer("Run")
		health -= 1
	else:
		health = 0
		kill()

func get_position_away_from_position(pos, angle, distance):
	return (Vector3(0,0,1).rotated(Vector3(0,1,0), deg_to_rad(angle)) * distance) + pos


func _on_awareness_body_entered(body):
	if body is Player:
		aware_of_player = true
		aware_length = 0

func _on_awareness_body_exited(body):
	if body is Player:
		aware_of_player = false
