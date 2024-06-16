extends Node3D

@onready var audio : AudioStreamPlayer3D = $AudioStreamPlayer3D

@export var OxygenRefillAmount : float
@export var RefillRate : float


var player : Node3D
var isInUse : bool = false
var oxygenRemaining : float

func _ready():
	player = get_node("/root/Main/Player")
	oxygenRemaining = OxygenRefillAmount
	
func _process(delta):
	if isInUse:
		if player.currentOxygen < player.MaxOxygenTime:
			player.ChangeOxygen(delta * RefillRate)
			oxygenRemaining -= delta * RefillRate
		else:
			OnCancelUse()
		
		if(oxygenRemaining <= 0):
			oxygenRemaining = 0
			OnCancelUse()

func OnItemUse():
	if oxygenRemaining > 0:
		isInUse = true
		player.DepleteOxygen = false
		audio.play(0)

func OnCancelUse():
	isInUse = false
	player.DepleteOxygen = true
	audio.stop()
