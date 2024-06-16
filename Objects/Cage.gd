class_name Cage

extends Node3D

var player_in_cage := true
var treasure_in_cage := false
var num_shark_in_cage := 0
var player_is_safe := true

signal player_reached_safety
signal player_in_danger

static var I : Cage

var initial_pos : Vector3

func _init():
	I = self

func _on_area_3d_body_entered(body):
	print(body, "entered")
	if body is Player:
		player_in_cage = true
		if Player.I.has_chest:
			treasure_in_cage = true
	if body is Shark:
		num_shark_in_cage += 1

func _on_area_3d_body_exited(body):
	print(body, "leave")
	if body is Player:
		player_in_cage = false
		if Player.I.has_chest:
			treasure_in_cage = false
	if body is Shark:
		num_shark_in_cage -= 1

func _on_door_on_close():
	if player_in_cage:
		player_is_safe = true
		player_reached_safety.emit()
	if num_shark_in_cage == 1:
		print("shark ending")
	if treasure_in_cage:
		leave()


func _on_door_on_open():
	player_is_safe = false
	player_in_danger.emit()
	
func leave():
	get_tree().create_tween().set_ease(Tween.EASE_IN).tween_property(self, "global_position:y", 150, 5)
	await get_tree().create_timer(3).timeout
	
	Player.I.win_game()
	
