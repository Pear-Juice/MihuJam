extends Node3D

var raycast : RayCast3D

func _ready():
	raycast = get_node("/root/Main/Player/Camera3D/RayCast3D")

func OnItemUse():
	var hit = raycast.get_collider() as Node3D
	if hit!= null && hit.name.contains("Shark"):
		hit.bonk()

func OnCancelUse():
	pass
