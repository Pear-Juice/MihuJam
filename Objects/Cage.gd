class_name Cage

extends Node3D

@export var end_music_curve : Curve

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
		leave()
	if treasure_in_cage:
		leave()


func _on_door_on_open():
	player_is_safe = false
	player_in_danger.emit()
	
func leave():
	await get_tree().create_timer(0.5).timeout
	
	Player.I.currentOxygen = Player.I.MaxOxygenTime
	Player.I.end_player.play(11)
	get_tree().create_tween().set_ease(Tween.EASE_IN).tween_property(Player.I.end_player, "volume_db", -10, 4)
	get_tree().create_tween().set_ease(Tween.EASE_IN).tween_property(self, "global_position:y", 450, 21)
	
	var world = get_tree().root.get_child(0).get_child(0) as WorldEnvironment
	get_tree().create_tween().tween_property(world.environment, "fog_light_color", Color("5186ff"), 7)
	await get_tree().create_timer(7).timeout
	Player.I.bootup_player.play()
	
	Player.I.win_game()
