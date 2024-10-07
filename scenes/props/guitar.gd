class_name GuitarProp extends PhysicsProp

@export var pick_sentitivity := 0.03
@export var pick: Node3D
@export var strings: Array[GuitarString]
@export_range(0, 10) var hand_pos: int
@export_range(0, 5) var finger_0_pos: int
@export_range(0, 5) var finger_1_pos: int
@export_range(0, 5) var finger_2_pos: int
@export_range(0, 5) var finger_3_pos: int
@export var hand: Node3D
@export var hand_slide_sound: AudioStreamPlayer3D

@export var min_pick_pos: Node3D
@export var max_pick_pos: Node3D

var _sfx_bus_volume: float = 0.0
var _voices_bus_volume: float = 0.0
var _is_playing := false
var _active_finger := 0

var _saved_chords := {}


func start_playing() -> void:
    $how_to_play.visible = true
    self.pick.visible = true
    self.hand.visible = true
    self._update_fingers()
    await self.get_tree().process_frame
    self._update_fingers()
    self._is_playing = true
    # self._sfx_bus_volume = AudioServer.get_bus_volume_db(1)
    # self._voices_bus_volume = AudioServer.get_bus_volume_db(2)
    # absolute rubbish
    for _i in 1000:
        var cur_sfx := AudioServer.get_bus_volume_db(1)
        var cur_voices := AudioServer.get_bus_volume_db(2)
        AudioServer.set_bus_volume_db(1, cur_sfx - 50.0 / 1000.0)
        AudioServer.set_bus_volume_db(2, cur_voices - 50.0 / 1000.0)
        await self.get_tree().process_frame


func stop_playing() -> void:
    $how_to_play.visible = false
    self.pick.visible = false
    self.hand.visible = false
    self._is_playing = false
    # pls dont laugh
    var sfx_diff := self._sfx_bus_volume - AudioServer.get_bus_volume_db(1)
    var voices_diff := self._voices_bus_volume - AudioServer.get_bus_volume_db(2)
    for _i in 1000:
        var cur_sfx := AudioServer.get_bus_volume_db(1)
        var cur_voices := AudioServer.get_bus_volume_db(2)
        AudioServer.set_bus_volume_db(1, cur_sfx + sfx_diff / 1000.0)
        AudioServer.set_bus_volume_db(2, cur_voices + voices_diff / 1000.0)
        await self.get_tree().process_frame


func _unhandled_input(event: InputEvent) -> void:
    if not self._is_playing:
        return

    self.get_viewport().set_input_as_handled()
    if event is InputEventMouseMotion:
        var mouse_motion_event := event as InputEventMouseMotion
        var relative_y := mouse_motion_event.relative.y
        self.move_pick(relative_y * Game.mouse_sensitivity * self.pick_sentitivity)
    elif event.is_action_pressed("jump"):
        # strum all strings
        var dist_to_min := self.pick.position.distance_to(self.min_pick_pos.position)
        var dist_to_max := self.pick.position.distance_to(self.max_pick_pos.position)

        var move_offset := dist_to_min
        if dist_to_min < dist_to_max:
            # move to max
            move_offset = -dist_to_max

        self.move_pick(move_offset)

    elif event.is_action_pressed("move left"):
        if Input.is_action_pressed("crouch"):
            self.set_hand_pos(hand_pos - 1)
        else:
            self._active_finger = clampi(self._active_finger - 1, 0, 3)
            self._highlight_finger()
    elif event.is_action_pressed("move right"):
        if Input.is_action_pressed("crouch"):
            self.set_hand_pos(hand_pos + 1)
        else:
            self._active_finger = clampi(self._active_finger + 1, 0, 3)
            self._highlight_finger()
    elif event.is_action_pressed("move forward"):
        self.move_finger(1)
    elif event.is_action_pressed("move backward"):
        self.move_finger(-1)
    elif event.is_action_pressed("1"):
        if Input.is_action_pressed("crouch"):
            self.save_chord(1)
        else:
            self.restore_chord(1)
    elif event.is_action_pressed("2"):
        if Input.is_action_pressed("crouch"):
            self.save_chord(2)
        else:
            self.restore_chord(2)
    elif event.is_action_pressed("3"):
        if Input.is_action_pressed("crouch"):
            self.save_chord(3)
        else:
            self.restore_chord(3)
    elif event.is_action_pressed("4"):
        if Input.is_action_pressed("crouch"):
            self.save_chord(4)
        else:
            self.restore_chord(4)
    elif event.is_action_pressed("5"):
        if Input.is_action_pressed("crouch"):
            self.save_chord(5)
        else:
            self.restore_chord(5)
    elif event.is_action_pressed("6"):
        if Input.is_action_pressed("crouch"):
            self.save_chord(6)
        else:
            self.restore_chord(6)
    elif event.is_action_pressed("7"):
        if Input.is_action_pressed("crouch"):
            self.save_chord(7)
        else:
            self.restore_chord(7)
    elif event.is_action_pressed("8"):
        if Input.is_action_pressed("crouch"):
            self.save_chord(8)
        else:
            self.restore_chord(8)
    elif event.is_action_pressed("9"):
        if Input.is_action_pressed("crouch"):
            self.save_chord(9)
        else:
            self.restore_chord(9)
    elif event.is_action_pressed("0"):
        if Input.is_action_pressed("crouch"):
            self.save_chord(0)
        else:
            self.restore_chord(0)


func save_chord(index: int) -> void:
    var saved_pos := {
        "hand": self.hand_pos,
        0: self.finger_0_pos,
        1: self.finger_1_pos,
        2: self.finger_2_pos,
        3: self.finger_3_pos,
    }
    self._saved_chords[index] = saved_pos


func restore_chord(index: int) -> void:
    if not self._saved_chords.has(index):
        return

    var chord = self._saved_chords[index]
    self.finger_0_pos = chord[0]
    self.finger_1_pos = chord[1]
    self.finger_2_pos = chord[2]
    self.finger_3_pos = chord[3]
    self.set_hand_pos(chord.hand)


func _highlight_finger() -> void:
    for child in self.hand.get_children():
        child.is_highlighted = false
    self.hand.get_child(self._active_finger).is_highlighted = true


func set_hand_pos(new_pos: int) -> void:
    new_pos = clampi(new_pos, 0, 10)
    if new_pos != self.hand_pos:
        self.hand_pos = new_pos
        self.hand_slide_sound.play()
        self._update_fingers()


func _update_fingers() -> void:
    var finger_0 := self.hand.get_child(0) as Node3D
    var finger_1 := self.hand.get_child(1) as Node3D
    var finger_2 := self.hand.get_child(2) as Node3D
    var finger_3 := self.hand.get_child(3) as Node3D

    # clear string pos
    for string in strings:
        string.finger_position = 0

    var index_string := self.strings[self.finger_0_pos]
    index_string.finger_position = self.hand_pos + 1
    index_string.adjust_pitch()
    finger_0.global_position = index_string.get_fret_pos()

    var middle_string := self.strings[self.finger_1_pos]
    middle_string.finger_position = self.hand_pos + 1
    middle_string.adjust_pitch()
    finger_1.global_position = middle_string.get_fret_pos()

    var ring_string := self.strings[self.finger_2_pos]
    ring_string.finger_position = self.hand_pos + 2
    ring_string.adjust_pitch()
    finger_2.global_position = ring_string.get_fret_pos()

    var pinky_string := self.strings[self.finger_3_pos]
    pinky_string.finger_position = self.hand_pos + 2
    pinky_string.adjust_pitch()
    finger_3.global_position = pinky_string.get_fret_pos()

    for string in strings:
        if self.hand_pos > string.finger_position or string.finger_position - self.hand_pos > 2:
            string.finger_position = hand_pos - 1
    self._highlight_finger()


func move_finger(offset: int) -> void:
    match self._active_finger:
        0:
            var new_pos := clampi(self.finger_0_pos + offset, 0, 5)
            if self.finger_1_pos == new_pos:
                if new_pos != 0 and new_pos != 5:
                    self.finger_0_pos = new_pos + offset
            # else don't move
            else:
                self.finger_0_pos = new_pos
        1:
            var new_pos := clampi(self.finger_1_pos + offset, 0, 5)
            if self.finger_0_pos == new_pos:
                if new_pos != 0 and new_pos != 5:
                    self.finger_1_pos = new_pos + offset
            # else don't move
            else:
                self.finger_1_pos = new_pos
        2:
            var new_pos := clampi(self.finger_2_pos + offset, 0, 5)
            if self.finger_3_pos == new_pos:
                if new_pos != 0 and new_pos != 5:
                    self.finger_2_pos = new_pos + offset
            # else don't move
            else:
                self.finger_2_pos = new_pos
        3:
            var new_pos := clampi(self.finger_3_pos + offset, 0, 5)
            if self.finger_2_pos == new_pos:
                if new_pos != 0 and new_pos != 5:
                    self.finger_3_pos = new_pos + offset
            # else don't move
            else:
                self.finger_3_pos = new_pos

    self._update_fingers()


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
