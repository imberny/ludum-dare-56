extends Area3D

@export var timer: Timer


func _ready() -> void:
	self.body_entered.connect(self._on_body_entered)
	self.body_exited.connect(self._on_body_exited)
	self.timer.timeout.connect(self._on_friend_timer_timeout)


func _on_body_entered(body) -> void:
	if not body is Player:
		return

	print("player in friend zone")
	if Game.friends >= 4:
		self.timer.start()


func _on_body_exited(body) -> void:
	if not body is Player:
		return

	print("player left friend zone")
	self.timer.stop()


func _on_friend_timer_timeout() -> void:
	Game.comfort()
