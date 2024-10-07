extends Node3D

@export var highlight_material: StandardMaterial3D

var is_highlighted := false:
	set = _set_is_highlighted


func _set_is_highlighted(value) -> void:
	is_highlighted = value
	if is_highlighted:
		$finger.set_surface_override_material(0, highlight_material)
	else:
		$finger.set_surface_override_material(0, null)
