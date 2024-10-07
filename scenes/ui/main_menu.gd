extends Control

@export var game_scene: PackedScene


func _on_start_button_pressed() -> void:
	self.add_sibling(self.game_scene.instantiate())
	self.visible = false
	Game.game_started = true
	self.queue_free()


func _on_quit_pressed() -> void:
	self.get_tree().quit()
