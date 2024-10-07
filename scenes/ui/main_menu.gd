extends Control

@export var game_scene: PackedScene

@export var audio: AudioStreamPlayer


func _on_start_button_pressed() -> void:
    self.create_tween().tween_property(self.audio, "volume_db", -100.0, Game.FADE_TIME)
    Game.fade_out()
    await Game.faded_out
    Game.fade_in()
    self.add_sibling(self.game_scene.instantiate())
    self.visible = false
    Game.game_started = true
    self.queue_free()


func _on_quit_pressed() -> void:
    self.get_tree().quit()
