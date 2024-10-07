# autoload Game
class_name GameManager extends Node

signal state_changed(new_state: State)
signal fading_out
signal faded_out
signal faded_in
signal turn_tv_on
signal guitar_picked_up
signal guitar_strummed
signal arpeggio

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
var joypad_look_sensitivity := 0.002

var actors := {}
var friends := 0
var talked_logan := -1
var dave_talked_to_logan := false
var game_started := false
var _menu: Control
var _previous_state: State

@onready var _black_screen := preload("res://scenes/ui/black.tscn").instantiate() as Control
@onready var _friends_timeline := preload("res://data/characters/friends.dtl") as DialogicTimeline
@onready var _end_scene := preload("res://scenes/ui/end_card.tscn") as PackedScene
@onready var _ingame_menu := preload("res://scenes/ui/ingame_menu.tscn") as PackedScene


func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	self._menu = self._ingame_menu.instantiate()
	self.state_changed.connect(self._on_state_changed)
	Dialogic.timeline_started.connect(self._on_dialogic_timeline_started)
	Dialogic.timeline_ended.connect(self._on_dialogic_timeline_ended)
	Dialogic.signal_event.connect(self._on_dialogic_signal_event)

	await self.get_tree().process_frame
	self.get_tree().root.add_child(self._black_screen)
	self.get_tree().root.add_child(self._menu)
	self._menu.visible = false


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


func comfort() -> void:
	self.state = State.CUTSCENE
	var logan := self.actors["Logan"] as Actor
	var layout = Dialogic.start(self._friends_timeline)
	layout.register_character(logan.character_file, logan.mouth)
	await Dialogic.timeline_ended
	self.fade_out()
	await self.faded_out
	self.get_tree().root.add_child(self._end_scene.instantiate())
	var volume := AudioServer.get_bus_volume_db(0)
	var delta_db := (volume - -100.0) / 200.0
	# stupid approach
	for _i in 200:
		var cur_volume := AudioServer.get_bus_volume_db(0)
		AudioServer.set_bus_volume_db(0, cur_volume - delta_db)
		await self.get_tree().process_frame


func _unhandled_input(event: InputEvent) -> void:
	if self.game_started and event.is_action_pressed("menu"):
		match self.state:
			Game.State.MENU:
				self.resume()
			Game.State.PLAYING:
				self._previous_state = self.state
				self.state = State.MENU


func resume() -> void:
	self.state = self._previous_state


func _on_state_changed(new_state: State) -> void:
	match new_state:
		State.MENU:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			self.get_tree().paused = true
			self._menu.visible = true
		State.CUTSCENE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			self._menu.visible = false
			self.get_tree().paused = false
		State.PLAYING:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			self._menu.visible = false
			self.get_tree().paused = false


func _on_dialogic_timeline_started() -> void:
	pass


func _on_dialogic_timeline_ended() -> void:
	pass


func _on_dialogic_signal_event(event: String) -> void:
	var parts := event.split(" ")
	if parts[0] == "play":
		if not self.actors.has(parts[1]):
			push_error("actor not found: %s" % parts[1])
			return
		var actor := self.actors[parts[1]] as Actor
		actor.animation = parts[2]
