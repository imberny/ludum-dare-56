@tool
class_name Actor extends Node3D

@export var animation: String:
    set = _set_animation
@export var mouth: Node3D
@export var character_file: DialogicCharacter

@onready var _anim_player := $AnimationPlayer as AnimationPlayer


func _ready() -> void:
    self._play(self.animation)


func _set_animation(value) -> void:
    if not self.is_node_ready():
        await self.ready
    if value == animation:
        return
    animation = value
    self._play(animation)


func _play(anim: String) -> void:
    if not self._anim_player.has_animation(anim):
        return
    self._anim_player.play(anim)
