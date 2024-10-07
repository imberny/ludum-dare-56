extends Button


func _ready() -> void:
	self.pressed.connect(self.get_tree().quit)


func _on_timer_timeout() -> void:
	self.visible = true
