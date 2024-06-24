extends Node3D

@export var search_color : Color
@export var pull_color : Color

@onready var target = $"Model/Armature/GeneralSkeleton/Target"
@onready var animator := $"Model/AnimationPlayer"

var player_in_sight : bool
var pull_force : float

func _ready():
	%Tongue/Light.light_color = search_color
	animator.play("Search")

func _process(delta):
	$Tongue.global_position = target.global_position
	$Tongue.global_rotation = target.global_rotation
	

func _on_sight_body_entered(body):
	if body is Player:
		player_in_sight = true
		%Tongue/Light.light_color = pull_color
		
func _on_sight_body_exited(body):
	if body is Player:
		player_in_sight = false
		%Tongue/Light.light_color = search_color
