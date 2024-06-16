class_name Cage

extends Node3D

var player_in_cage := true
var num_shark_in_cage := 0
var player_is_safe := true

signal player_reached_safety
signal player_in_danger

static var I : Cage

var initial_pos : Vector3

func _init():
	I = self

func _on_area_3d_body_entered(body):
	print(body, )
	if body is Player:
		player_in_cage = true
	if body is Shark:
		num_shark_in_cage += 1
		print("shark enter")

func _on_area_3d_body_exited(body):
	print(body, "leave")
	if body is Player:
		player_in_cage = false
	if body is Shark:
		num_shark_in_cage -= 1
		print("shark leave")

func _on_door_on_close():
	if player_in_cage:
		player_is_safe = true
		player_reached_safety.emit()
	if num_shark_in_cage == 1:
		print("shark ending")


func _on_door_on_open():
	player_is_safe = false
	player_in_danger.emit()
