extends Control


func _on_resume_pressed() -> void:
	Game.resume()


func _on_quit_pressed() -> void:
	self.get_tree().quit()
