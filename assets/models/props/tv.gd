extends Node3D

@export var off_material: StandardMaterial3D
@export var viewport_material: StandardMaterial3D
@export var viewport: Viewport

var _is_on := false


func _ready() -> void:
	self.turn_off()
	await self.get_tree().process_frame
	self.viewport_material.albedo_texture = viewport.get_texture()


func turn_on() -> void:
	self._is_on = true
	$sound.play()
	$tv.set_surface_override_material(1, viewport_material)


func turn_off() -> void:
	self._is_on = false
	$sound.stop()
	$tv.set_surface_override_material(1, off_material)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		if self._is_on:
			self.turn_off()
		else:
			self.turn_on()
