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
	for participant in participants:
		layout.register_character(participant.character_file, participant)
	self._has_played = true


func has_content() -> bool:
	return not self._has_played
