extends Node3D

var is_open : bool

@export var close_rot : int
@export var open_rot : int

@export var cooldown_length_sec := 5.0
var time_since_close_sec := 0.0

signal on_close
signal on_open

func interact(hand):
	switch_state()
	
func switch_state():
	if !is_open:
		open(0.5)
	else:
		close(1)
	
func open(duration_sec : float):
	is_open = true
	get_tree().create_tween().set_ease(Tween.EASE_IN).tween_property(self, "rotation_degrees:y", open_rot, duration_sec)
	%DoorOpenSlow.play()
	on_open.emit()
	
func close(duration_sec : float):
	is_open = false
	get_tree().create_tween().set_ease(Tween.EASE_IN).tween_property(self, "rotation_degrees:y", close_rot, duration_sec)
	%DoorClose.play()
	time_since_close_sec = 0
	on_close.emit()
