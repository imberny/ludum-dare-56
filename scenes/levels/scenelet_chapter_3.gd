extends Node3D


func _ready() -> void:
	await self.get_tree().process_frame
	Game.state = Game.State.PLAYING
	Game.turn_tv_on.emit()
