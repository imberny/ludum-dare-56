class_name SceneletTrigger extends Area3D

@export var timeline_file: DialogicTimeline
@export var participants: Array[TalkingActor]

var _has_played := false


func start() -> void:
	if self._has_played:
		push_warning("Attempting to replay a scenelet. Aborting")
		return
	if Dialogic.current_timeline:
		push_error("Timeline already playing %s" % Dialogic.current_timeline.resource_path)
		return

	var layout := Dialogic.start(self.timeline_file)
	self._has_played = true
	if not layout.has_method("register_character"):
		return
	for participant in participants:
		layout.register_character(participant.character_file, participant)
	Dialogic.timeline_ended.connect(self._on_dialogic_timeline_ended.bind(layout))


func has_content() -> bool:
	return not self._has_played


func _on_dialogic_timeline_ended(layout) -> void:
	# some weird resource shenanigans. Basically, I have to manually unregister characters,
	# or else the same character in another scenelet will not get properly registered somehow.
	# However, if every timeline has been played already, then the layout has been freed before
	# the timeline ended signal is emitted.
	if not is_instance_valid(layout):
		return
	if layout.has_method("register_character"):
		for participant in self.participants:
			layout.registered_characters.erase(participant.character_file)
