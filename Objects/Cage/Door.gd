extends Node3D

var is_open : bool

@export var close_rot : int
@export var open_rot : int

var time_since_close_sec : float
@onready var max_close_time := randi_range(5, 60)

signal on_close
signal on_open

func interact(hand):
	switch_state()
		
func _process(delta):
	if !is_open && get_parent().player_in_cage:
		time_since_close_sec += delta
		if time_since_close_sec > max_close_time:
			open_slow()
	
func switch_state():
	if !is_open:
		is_open = true
		get_tree().create_tween().set_ease(Tween.EASE_IN).tween_property(self, "rotation_degrees:y", open_rot, 0.5)
		%DoorOpen.play()
		on_open.emit()
		
	else:
		is_open = false
		get_tree().create_tween().set_ease(Tween.EASE_IN).tween_property(self, "rotation_degrees:y", close_rot, 1)
		%DoorClose.play()
		time_since_close_sec = 0
		max_close_time = randi_range(5, 60)
		on_close.emit()
		
func open_slow():
	is_open = true
	get_tree().create_tween().set_ease(Tween.EASE_IN).tween_property(self, "rotation_degrees:y", open_rot, 4)
	%DoorOpenSlow.play()
	on_open.emit()
