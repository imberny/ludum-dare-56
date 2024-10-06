class_name AudioStreamLooper extends AudioStreamPlayer3D

@export var interval := 0.0
@export var interval_randomness := 15.0


func _ready() -> void:
	self.finished.connect(self._on_finished)


func start_looping() -> void:
	self.play()


func _on_finished() -> void:
	var delay := interval + randf() * interval_randomness
	await self.get_tree().create_timer(delay).timeout
	self.play()
