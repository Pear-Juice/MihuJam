@tool

extends Node3D

@export var reload : bool:
	set(_val):
		update()
		
@export var light_height := 14.0
@export var light_angle:= 33.0
@export var light_energy := 16.0
@export var light_fog_energy := 50
@export var partical_lifetime := 3.0
@export var turbulence_stength := 0.03
	
func _ready():
	update()
	
func update():
	$Light.spot_range = light_height
	$Light.spot_angle = light_angle
	$Light.light_energy = light_energy
	$Light.light_volumetric_fog_energy = light_fog_energy
	$Partical.lifetime = partical_lifetime
	$Partical.process_material.set("turbulence_influence_max", turbulence_stength)
