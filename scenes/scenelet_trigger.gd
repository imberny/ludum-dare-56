class_name SceneletTrigger extends Area3D

@export var timeline_file: DialogicTimeline
@export var participants: Array[TalkingActor]


func start() -> void:
	if Dialogic.current_timeline:
		push_error("Timeline already playing %s" % Dialogic.current_timeline.resource_path)
		return

	var layout := Dialogic.start(self.timeline_file)
	for participant in participants:
		layout.register_character(participant.character_file, participant)
