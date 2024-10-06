# autoload Game
class_name GameManager extends Node

signal state_changed(new_state: State)
signal fading_out
signal faded_out
signal faded_in

enum State { MENU, CUTSCENE, PLAYING }

const FADE_TIME := 1.0
const AFTER_FADEOUT_TIME := 0.3

var state := State.MENU:
    set(value):
        if value == state:
            return
        state = value
        self.state_changed.emit(state)
var mouse_sensitivity := 0.002

var logan: Actor

@onready var _black_screen := preload("res://scenes/ui/black.tscn").instantiate() as Control


func _ready() -> void:
    self.state_changed.connect(self._on_state_changed)
    Dialogic.timeline_started.connect(self._on_dialogic_timeline_started)
    Dialogic.timeline_ended.connect(self._on_dialogic_timeline_ended)

    await self.get_tree().process_frame
    self.get_tree().root.add_child(self._black_screen)


func fade_in() -> void:
    await (
        self
        . create_tween()
        . tween_property(self._black_screen, "modulate:a", 0.0, FADE_TIME)
        . finished
    )
    self.faded_in.emit()


func fade_out() -> void:
    self.fading_out.emit()
    await (
        self
        . create_tween()
        . tween_property(self._black_screen, "modulate:a", 1.0, FADE_TIME)
        . finished
    )
    await self.get_tree().create_timer(AFTER_FADEOUT_TIME).timeout
    self.faded_out.emit()


func eat_cake() -> void:
    print("eating cake")


func logan_leave_table() -> void:
    if self.logan:
        self.logan.animation = "leave"


func tom_passes_cake() -> void:
    pass


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
    pass


func _on_dialogic_timeline_ended() -> void:
    pass
