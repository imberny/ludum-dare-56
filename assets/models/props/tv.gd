extends Node3D

@export var off_material: StandardMaterial3D
@export var viewport_material: StandardMaterial3D
@export var viewport: Viewport
@export var light_energy := 5.0

var _is_on := false


func _ready() -> void:
    self.turn_off()
    await self.get_tree().process_frame
    self.viewport_material.albedo_texture = viewport.get_texture()
    Game.turn_tv_on.connect(self.turn_on)


func turn_on() -> void:
    self._is_on = true
    $sound.play()
    $tv.set_surface_override_material(1, viewport_material)
    $omni_light_3d.light_energy = self.light_energy
    $omni_light_3d.visible = true


func turn_off() -> void:
    self._is_on = false
    $sound.stop()
    $tv.set_surface_override_material(1, off_material)
    $omni_light_3d.visible = false
