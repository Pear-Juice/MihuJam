class_name Cage

extends Node3D


static var I : Cage

var initial_pos : Vector3

func _init():
	I = self

func _ready():
	initial_pos = global_position
	global_position.y += 50
	
	get_tree().create_tween().tween_property(self, "global_position:y", 0, 10)
	
	
