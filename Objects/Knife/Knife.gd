extends Node3D

var raycast : RayCast3D

@export var knife_model : Node3D

func _ready():
	raycast = get_node("/root/Main/Player/Camera3D/RayCast3D")

func OnItemUse():
	print("use knife")
	var hit = raycast.get_collider() as Node3D
	if hit:
		print(hit.name)
	if hit && (hit.name.contains("Shark") || hit.name.contains("Worm")):
		hit.bonk()
		
	var tween = get_tree().create_tween().tween_property(knife_model, "position:z", -1,0.1)
	await tween.finished
	get_tree().create_tween().tween_property(knife_model, "position:z", 0,0.1)

func OnCancelUse():
	pass
