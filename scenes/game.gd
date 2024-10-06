# autoload Game
class_name GameManager extends Node

signal state_changed(new_state: State)

enum State { MENU, CUTSCENE, PLAYING }

var state := State.MENU:
	set(value):
		if value == state:
			return
		state = value
		self.state_changed.emit(state)
var mouse_sensitivity := 0.002


func _ready() -> void:
	self.state_changed.connect(self._on_state_changed)
	Dialogic.timeline_started.connect(self._on_dialogic_timeline_started)
	Dialogic.timeline_ended.connect(self._on_dialogic_timeline_ended)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		self.get_tree().quit()


func _on_state_changed(new_state: State) -> void:
	match new_state:
		State.MENU:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		State.CUTSCENE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		State.PLAYING:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_dialogic_timeline_started() -> void:
	self.state = State.CUTSCENE


func _on_dialogic_timeline_ended() -> void:
	self.state = State.PLAYING
