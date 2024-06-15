extends Node3D

@onready var light = $SpotLight3D
@onready var sound = $AudioStreamPlayer3D as AudioStreamPlayer3D

@export var Active : bool = true
@export var BatteryTime: float

var currentBattery : float

func _ready():
	SetFlashlightState(Active)
	currentBattery = BatteryTime
	
func _process(delta):
	if(Active):
		currentBattery -= delta
		if(currentBattery <= 0):
			Active = false
			SetFlashlightState(Active)

func OnItemUse():
	if(currentBattery <= 0):
		Active = false
		return
	
	Active = !Active
	SetFlashlightState(Active)

func SetFlashlightState(state):
	light.visible = state
	sound.play(0)
