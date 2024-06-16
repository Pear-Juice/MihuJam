extends Node


func _ready():
	$Buzz.play()
	var tween = get_tree().create_tween().tween_property($List, "global_position:y", -197, 20)
	await tween.finished
	
	
	$Click.play()
	await $Click.finished
	get_tree().change_scene_to_file("res://Scenes/Home.tscn")
	
	
