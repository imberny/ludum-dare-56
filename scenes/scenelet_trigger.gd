class_name SceneletTrigger extends Area3D

@export var timeline_file: DialogicTimeline
@export var participants: Array[Actor]
@export var next_scenelet: PackedScene
@export var autoplay: bool
@export var is_oneshot: bool
@export var switch_on_finished: bool
@export var use_fade_to_black: bool

var _play_count := 0


func _ready() -> void:
	if self.autoplay:
		await self.get_tree().create_timer(0.1).timeout
		self.start()


func has_content() -> bool:
	if self.is_oneshot and self._play_count > 0:
		return false
	return true


func start() -> void:
	if Dialogic.current_timeline:
		push_error("Timeline already playing %s" % Dialogic.current_timeline.resource_path)
		return

	self._play_count += 1
	var layout := Dialogic.start(self.timeline_file)
	if not layout.has_method("register_character"):
		return
	for participant in participants:
		layout.register_character(participant.character_file, participant.mouth)
	Game.state = Game.State.CUTSCENE

	await Dialogic.timeline_ended

	if not self.has_content():
		if self.use_fade_to_black:
			Game.fade_out()
			await Game.faded_out
			Game.fade_in()
		Game.state = Game.State.PLAYING
		self.add_sibling(self.next_scenelet.instantiate())
		self.queue_free()

	# some weird resource shenanigans. Basically, I have to manually unregister characters,
	# or else the same character in another scenelet will not get properly registered somehow.
	# However, if every timeline has been played already, then the layout has been freed before
	# the timeline ended signal is emitted.
	if not is_instance_valid(layout):
		return
	if layout.has_method("register_character"):
		for participant in self.participants:
			layout.registered_characters.erase(participant.character_file)
