class_name GuitarProp extends PhysicsProp

@export var pick_sentitivity := 0.03
@export var pick: Node3D
@export var strings: Array[GuitarString]

@export var min_pick_pos: Node3D
@export var max_pick_pos: Node3D


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_motion_event := event as InputEventMouseMotion
		var relative_y := mouse_motion_event.relative.y
		self.move_pick(relative_y * Game.mouse_sensitivity * self.pick_sentitivity)


func move_pick(y_offset: float) -> void:
	var pick_pos := self.pick.position

	# mouse down mean pluck up, mouse up mean pluck down
	# Since guitar is upright, down is Vector x positive
	var next_pick_pos := pick_pos + y_offset * Vector3.LEFT
	next_pick_pos.x = clampf(
		next_pick_pos.x, self.min_pick_pos.position.x, self.max_pick_pos.position.x
	)

	for string in self.strings:
		var string_pos_x := string.position.x
		var x0 := pick_pos.x
		var x1 := next_pick_pos.x
		var is_plucked: bool = min(x0, x1) < string_pos_x and string_pos_x < max(x0, x1)
		if is_plucked:
			string.pluck()

	self.pick.position = next_pick_pos
