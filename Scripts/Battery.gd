extends Node3D

var player : Node3D

@export var BatteryRecovery : float

func _ready():
	player = get_node("/root/Main/Player")

func OnItemUse():
	print("hi")
	var flashlight = player.CheckHandsForItem("Flashlight")
	if(flashlight != null):
		flashlight.Recharge(BatteryRecovery)
		queue_free()

func OnCancelUse():
	pass
