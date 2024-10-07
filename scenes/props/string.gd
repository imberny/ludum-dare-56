@tool
class_name GuitarString extends MeshInstance3D

@export var start: Node3D
@export var end: Node3D
@export var width := 0.1
@export var resolution := 40
@export var max_vibration := 0.005
@export var frequency := 100.0
@export var sound: AudioStreamPlayer3D
@export_range(0, 12) var finger_position := 0:
    set = _set_finger_position

@export var pos_to_pitch: Array[float]

@export var test_pluck: bool:
    set = _test_pluck

var _time := 0.0
var _vibe := 0.0
var _is_muted := false
@onready var _tween: Tween
@onready var _frets := $frets as Node3D


func _ready() -> void:
    # just so the debugger shuts up
    self._tween = self.create_tween()
    self._tween.tween_interval(0.1)


func _process(delta: float) -> void:
    self._time += delta

    mesh.clear_surfaces()

    mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)

    var start_pos := self.start.position
    var end_pos := self.end.position
    var length := start_pos.distance_to(end_pos)
    var dir := start_pos.direction_to(end_pos)
    var cross := dir.cross(Vector3.BACK)
    var width_offset := cross * self.width * 0.5
    var step := length / float(resolution)
    for i in resolution:
        var vibe_offset := cross * self._vibe * sin((i * step) * self.frequency)
        var next_vibe_offset := cross * self._vibe * sin(((i + 1) * step) * self.frequency)
        if i == 0:
            vibe_offset = Vector3.ZERO
        if i == resolution - 1:
            next_vibe_offset = Vector3.ZERO

        var v1 := start_pos + i * step * dir + width_offset + vibe_offset
        var v2 := start_pos + i * step * dir - width_offset + vibe_offset
        var v3 := start_pos + (i + 1) * step * dir + width_offset + next_vibe_offset
        var v4 := start_pos + (i + 1) * step * dir - width_offset + next_vibe_offset

        mesh.surface_add_vertex(v1)
        mesh.surface_add_vertex(v2)
        mesh.surface_add_vertex(v3)
        mesh.surface_add_vertex(v3)
        mesh.surface_add_vertex(v2)
        mesh.surface_add_vertex(v4)

    mesh.surface_end()


func pluck() -> void:
    if self._is_muted:
        return

    self.sound.play()
    self._vibe = self.max_vibration
    self._tween.kill()
    self._tween = self.create_tween()

    self._tween.tween_property(self, "_vibe", 0.0, 0.2)


func mute() -> void:
    self._is_muted = true
    self.sound.stop()


func unmute() -> void:
    self._is_muted = false


func _test_pluck(_value) -> void:
    self.pluck()


func get_fret_pos() -> Vector3:
    var current_fret := self._frets.get_child(self.finger_position) as Node3D
    return current_fret.global_position


func _set_finger_position(value) -> void:
    if value == finger_position:
        return

    # self.sound.stop()
    finger_position = value
    if not self.is_node_ready():
        await self.ready
    self.sound.pitch_scale = self.pos_to_pitch[value]
