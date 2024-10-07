@tool
class_name Actor extends Node3D

@export var animation: String:
	set = _set_animation
@export var mouth: Node3D
@export var character_file: DialogicCharacter
@export var looping_audio: Array[AudioStreamLooper]

@onready var _anim_player := $AnimationPlayer as AnimationPlayer


func _ready() -> void:
	self._play(self.animation)
	if not Engine.is_editor_hint():
		self.talk_loop()
		Game.actors[self.character_file.display_name] = self


func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return


func talk_loop() -> void:
	for audio in self.looping_audio:
		audio.start_looping()


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


func fade_out() -> void:
	for audio in self.looping_audio:
		self.create_tween().tween_property(audio, "volume_db", -100.0, Game.FADE_TIME)
