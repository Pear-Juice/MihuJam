extends Node

#func _ready():
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

const main = preload("res://Scenes/Main.tscn")

func _on_play_button_up():
	var main_obj = main.instantiate()
	
	get_tree().root.add_child(main_obj)
	get_tree().current_scene = main_obj
	queue_free()


func _on_controls_button_up():
	get_tree().change_scene_to_file("res://Scenes/Controls.tscn")


func _on_exit_button_up():
	get_tree().quit()
