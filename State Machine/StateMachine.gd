class_name StateMachine

extends Node

var state_array : Array[State]
var current_state : State
var debug : bool
var delta : float

static func create(base : Node):
	var new_machine = StateMachine.new()
	base.add_child(new_machine)
	
	return new_machine
	
func add_state(state_name : String, begin_func = null, run_func = null, exit_func = null):
	var state = State.new()
	state.state_name = state_name
	state.begin = begin_func
	state.run = run_func
	state.exit = exit_func
	state_array.append(state)

func transfer(state_name : String):
	if debug:
		if current_state:
			prints("Transfer from:", current_state.state_name, "to", state_name)
		else:
			prints("Transfer to", state_name)
	
	if current_state && current_state.exit:
		current_state.exit.call()
		if debug:
			prints("	Exit", current_state.state_name)
	
	var found_state := false
	for state in state_array:
		if state.state_name == state_name:
			current_state = state
			found_state = true
	
	if !found_state:
		print("Error: State not found")
		return
		
	if current_state && current_state.begin:
		current_state.elapsed_time = 0
		current_state.begin.call()
		
		if debug:
			prints("	Enter", current_state.state_name)
	
	if debug:
		print("Transfer complete")
	
func _process(delta):
	if current_state && current_state.run:
		current_state.run.call(delta)
		current_state.elapsed_time += delta
