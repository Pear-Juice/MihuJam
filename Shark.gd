extends CharacterBody3D

var state_m : StateMachine

func _ready():
	state_m = StateMachine.create(self)
	
	state_m.add_state("Patrol", patrol_state)
	state_m.add_state("Circle", circle_state)
	state_m.add_state("Chase", chase_state)
	state_m.add_state("Run", run_state)
	state_m.add_state("Eat", eat_state)
	
	state_m.transfer("Patrol")

func patrol_state():
	
	await get_tree().create_timer(randf_range(60,180)).timeout
	state_m.transfer("Circle")
	
func circle_state():
	state_m.transfer("Chase")
	pass
	
func chase_state():
	pass
	
func run_state():
	pass
	
func eat_state():
	pass
