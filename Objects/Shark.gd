extends CharacterBody3D

@export var patrol_speed : float
@export var circle_speed : float
@export var chase_speed : float
var current_speed : float

var target : Vector3
var state_m : StateMachine

func _ready():
	state_m = StateMachine.create(self)
	
	state_m.add_state("Patrol", patrol_state)
	state_m.add_state("Circle", circle_state)
	state_m.add_state("Chase", chase_state, chase_state_run)
	state_m.add_state("Ram", ram_state)
	state_m.add_state("Run", run_state)
	state_m.add_state("Eat", eat_state)
	
	state_m.debug = true
	state_m.transfer("Patrol")
	
func _physics_process(delta):
	velocity = global_position.direction_to(target) * current_speed
	move_and_slide()

func patrol_state():
	current_speed = patrol_speed
	get_tree().create_timer(randf_range(60,180)).timeout.connect(func(): state_m.transfer("Circle"), Node.CONNECT_ONE_SHOT)
	
func circle_state():
	current_speed = circle_speed
	get_tree().create_timer(randf_range(30,60)).timeout.connect(func(): state_m.transfer("Patrol"), Node.CONNECT_ONE_SHOT)
	
func circle_state_run():
	pass
	
func chase_state():
	current_speed = chase_speed
	
func chase_state_run():
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
