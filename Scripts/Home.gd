extends Node

func _ready():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_play_button_up():
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")


func _on_controls_button_up():
	get_tree().change_scene_to_file("res://Scenes/Controls.tscn")


func _on_exit_button_up():
	get_tree().quit()
