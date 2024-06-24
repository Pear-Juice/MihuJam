@tool

extends Node3D

@export var air_fill_rate : float
@export var off_range : Vector2
@export var on_range : Vector2
var active : bool
var player_in_bubbles :  bool

@export var reload : bool:
	set(_val):
		update_props()

@export var light_color := Color("ff0ea0")
@export var light_height := 14.0
@export var light_angle:= 33.0
@export var light_energy := 16.0
@export var light_fog_energy := 50
@export var partical_lifetime := 3.0
@export var turbulence_stength := 0.03
	
func _ready():
	update_props()
	
	if !Engine.is_editor_hint():
		on_off_loop()
	
func update_props():
	$Light.light_color = light_color
	$Light.spot_range = light_height
	$Light.spot_angle = light_angle
	$Light.light_energy = light_energy
	$Light.light_volumetric_fog_energy = light_fog_energy
	$Partical.lifetime = partical_lifetime
	$Partical.process_material.set("turbulence_influence_max", turbulence_stength)

func on_off_loop():
	while true:
		if !active:
			activate()
			await get_tree().create_timer(randf_range(on_range.x, on_range.y)).timeout
		else:
			deactivate()
			await get_tree().create_timer(randf_range(off_range.x, off_range.y)).timeout
			

func activate():
	active = true
	$Light.visible = true
	$Partical.emitting = true
	
func deactivate():
	active = false
	$Light.visible = false
	$Partical.emitting = false

func _process(delta):
	if player_in_bubbles && active:
		Player.I.ChangeOxygen(delta * air_fill_rate)

func _on_bubbles_body_entered(body):
	if body is Player:
		player_in_bubbles = true

func _on_bubbles_body_exited(body):
	if body is Player:
		player_in_bubbles = false
