class_name Shark

extends CharacterBody3D

@export var min_retarget_dist : float

@export var patrol_speed : float
@export var circle_speed : float
var circle_close_dist : float
var circle_far_dist : float
@export var chase_speed : float
var current_speed : float

var target : Vector3
var lerp_target : Vector3
var target_angle : int
var state_m : StateMachine

var lerp_multiplier = 2

func _ready():
	state_m = StateMachine.create(self)
	
	state_m.add_state("Patrol", patrol_state, patrol_state_run)
	state_m.add_state("Circle", circle_state, circle_state_run)
	state_m.add_state("Chase", chase_state, chase_state_run)
	state_m.add_state("Ram", ram_state)
	state_m.add_state("Run", run_state)
	state_m.add_state("Eat", eat_state)
	
	state_m.debug = true
	state_m.transfer("Patrol")
	
	print(Cage.I.global_position, (Vector3(0,0,1).rotated(Vector3(0,1,0), deg_to_rad(target_angle)) * 10) + Cage.I.global_position)
	
func _physics_process(delta):
	lerp_target = lerp_target.slerp(target, delta * lerp_multiplier)
	$Target.global_position = lerp_target
	look_at(lerp_target)
	velocity = global_position.direction_to(target) * current_speed
	move_and_slide()

func patrol_state():
	current_speed = patrol_speed
	get_tree().create_timer(randf_range(60,180)).timeout.connect(func(): state_m.transfer("Circle"), Node.CONNECT_ONE_SHOT)
	
func patrol_state_run(delta):
	if global_position.distance_to(target) < min_retarget_dist:
		target_angle += 20
		target = get_position_away_from_position(Cage.I.global_position, target_angle, randi_range(8,12))
	
func circle_state():
	current_speed = circle_speed
	get_tree().create_timer(randf_range(30,60)).timeout.connect(func(): state_m.transfer("Patrol"), Node.CONNECT_ONE_SHOT)
	
func circle_state_run(delta):
	if global_position.distance_to(target) < min_retarget_dist:
		print("move target")
	
func chase_state():
	current_speed = chase_speed
	
func chase_state_run(delta):
	if target.distance_to(Player.I.global_position) > 1:
		#lerp_target = target.lerp(Player.I.global_position, delta * lerp_multiplier)
		target = Player.I.global_position
	
func ram_state():
	current_speed = chase_speed
	state_m.transfer("Circle")
	
func run_state():
	current_speed = chase_speed
	state_m.transfer("Patrol")
	
func eat_state():
	print("Player died!")

func _on_sight_entered(body):
	if body is Player:
		state_m.transfer("Chase")

func _on_eat_body_entered(body):
	if body is Player:
		state_m.transfer("Eat")
		
func player_escaped():
	state_m.transfer("Circle")

func get_position_away_from_position(pos, angle, distance):
	return (Vector3(0,0,1).rotated(Vector3(0,1,0), deg_to_rad(angle)) * distance) + pos
