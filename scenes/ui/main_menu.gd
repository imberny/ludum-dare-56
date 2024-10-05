extends Control

@export var game_scene: PackedScene


func _on_start_button_pressed() -> void:
    self.add_sibling(self.game_scene.instantiate())
    self.visible = false
    await self.get_tree().process_frame
    Game.state = Game.State.PLAYING
