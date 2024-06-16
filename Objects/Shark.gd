class_name Shark

extends CharacterBody3D

@export var min_retarget_dist : float

@export var patrol_speed : float
@export var min_patrol_distance : int
@export var patrol_length_sec : int
@export var circle_speed : float
@export var min_circle_distance : int
@export var circle_length_sec : int
var circle_close_dist : float
var circle_far_dist : float
@export var chase_speed : float
var current_speed : float

var is_targeting : bool
var target : Vector3
var lerp_target : Vector3
var target_angle := 180
var state_m : StateMachine
var state_length_mod : int

var lerp_multiplier = 3.5

var aware_of_player : bool
var aware_length : float
var player_in_sight : bool

var health = 3

@export var aware_length_threshold : float

@export var wiggle_curve : Curve
@export var wiggle_amp : float
@export var wiggle_speed : int

@export var approach_curve : Curve
@export var approach_amp : float
@export var approach_speed : float


func _ready():
	state_m = StateMachine.create(self)
	
	state_m.add_state("Patrol", patrol_state, patrol_state_run)
	state_m.add_state("Circle", circle_state, circle_state_run)
	state_m.add_state("Chase", chase_state, chase_state_run)
	state_m.add_state("Ram", ram_state)
	state_m.add_state("Run", run_state, run_state_run)
	state_m.add_state("Eat", eat_state)
	
	state_m.debug = true
	
	spawn()
	
func spawn():
	is_targeting = true
	target_angle = 180
	target = get_position_away_from_position(Cage.I.global_position, target_angle, min_circle_distance)
	global_position = target
	state_m.transfer("Circle")
	
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
	state_length_mod = randi_range(-20,20)
	
func patrol_state_run(delta):
	if state_m.current_state.elapsed_time > patrol_length_sec + state_length_mod:
		state_m.transfer("Circle")
	
	if aware_of_player:
		if aware_length > aware_length_threshold && !Cage.I.player_is_safe:
			state_m.transfer("Chase")
		aware_length += delta
	
	if global_position.distance_to(target) < min_retarget_dist:
		target_angle += 2
		
		var wiggle_distance = (wiggle_curve.sample((target_angle * wiggle_speed % 360) / 360.0) * wiggle_amp)
		var approach_distance = (approach_curve.sample((int(target_angle * approach_speed) % 360) / 360.0) * approach_amp)
		
		target = get_position_away_from_position(Cage.I.global_position, target_angle, wiggle_distance + approach_distance + min_patrol_distance)

func circle_state():
	
	current_speed = circle_speed
	state_length_mod = randi_range(-20,20)
	
func circle_state_run(delta):
	if state_m.current_state.elapsed_time > circle_length_sec + state_length_mod:
		state_m.transfer("Patrol")
		
	if aware_of_player:
		if aware_length > aware_length_threshold && !Cage.I.player_is_safe:
			state_m.transfer("Chase")
		aware_length += delta
	
	if global_position.distance_to(target) < min_retarget_dist:
		target_angle += 2
		
		var wiggle_distance = (wiggle_curve.sample((target_angle * wiggle_speed % 360) / 360.0) * wiggle_amp)
		var approach_distance = (approach_curve.sample((int(target_angle * approach_speed) % 360) / 360.0) * approach_amp)
		
		target = get_position_away_from_position(Cage.I.global_position, target_angle, wiggle_distance + approach_distance + min_circle_distance)
	
func chase_state():
	current_speed = chase_speed
	
func chase_state_run(delta):
	target = Player.I.global_position
	
	if Cage.I.player_is_safe:
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
	current_speed = chase_speed
	
	target = get_position_away_from_position(Cage.I.global_position, target_angle, 30)
	
func run_state_run(delta):
	if global_position.distance_to(target) < min_retarget_dist:
		state_m.transfer("Patrol")

func _on_sight_entered(body):
	if body is Player  && !Cage.I.player_is_safe:
		print("sight entered")
		player_in_sight = true
		state_m.transfer("Chase")
		
func _on_sight_body_exited(body):
	if body is Player:
		player_in_sight = false
		player_escaped()

func _on_eat_body_entered(body):
	if body is Player:
		state_m.transfer("Eat")
		
func player_escaped():
	state_m.transfer("Circle")
	
func kill():
	get_tree().create_tween().tween_property(self, "rotation:z", 180, 0.3)
	
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
