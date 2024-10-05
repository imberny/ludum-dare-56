extends CharacterBody3D

@export var jump_impulse := 4.5
@export var acceleration := 5.0
@export var deceleration := 8.0
@export var max_speed := 3.0
@export var downward_gravity_factor := 1.3
@export var hold_drag_force := 4.5

var _horizontal_velocity := Vector3.ZERO
var _vertical_velocity := Vector3.ZERO
var _can_talk := true:
    set(value):
        if value == _can_talk:
            return
        _can_talk = value
        self._talk_label.visible = _can_talk
var _can_pickup := true:
    set(value):
        if value == _can_pickup:
            return
        _can_pickup = value
        self._pickup_label.visible = _can_pickup
var _held_prop: PhysicsProp
var _is_player_controlling := false
var _is_crouched := false

@onready var _camera := $camera as Camera3D
@onready var _ray := $camera/interaction_ray as RayCast3D
@onready var _talk_label := $talk as Label
@onready var _pickup_label := $pickup as Label
@onready var _hold_point := $hold_point as Node3D


func _ready() -> void:
    Game.state_changed.connect(self._on_game_state_changed)


func _unhandled_input(event: InputEvent) -> void:
    if not self._is_player_controlling:
        return

    if self.is_on_floor() and event.is_action_pressed("jump"):
        self._vertical_velocity = self.jump_impulse * Vector3.UP
    elif event.is_action_pressed("interact"):
        self._try_interact()
    elif event.is_action_pressed("crouch"):
        self._is_crouched = true
    elif event.is_action_released("crouch"):
        self._is_crouched = false
    elif event is InputEventMouseMotion:
        var mouse_motion_event := event as InputEventMouseMotion
        rotate_y(-mouse_motion_event.relative.x * Game.mouse_sensitivity)
        self._camera.rotate_x(-mouse_motion_event.relative.y * Game.mouse_sensitivity)


func _try_interact() -> void:
    if not self._can_talk and self._held_prop:
        self._drop()
        return

    if not self._ray.is_colliding():
        return

    var picked_object := self._ray.get_collider()
    if picked_object is SceneletTrigger:
        picked_object.start()
    elif picked_object is PhysicsProp:
        self._held_prop = picked_object
        self._held_prop.grab()


func _drop() -> void:
    self._held_prop.drop()
    self._held_prop = null


func _physics_process(delta: float) -> void:
    self._pick()
    self._move(delta)
    self._drag_held_object(delta)
    self._adjust_camera_height(delta)


func _pick() -> void:
    if not self._is_player_controlling or not self._ray.is_colliding():
        self._can_talk = false
        self._can_pickup = false
        return

    var picked_object := self._ray.get_collider()
    self._can_talk = picked_object is SceneletTrigger
    if picked_object is SceneletTrigger:
        self._can_talk = picked_object.has_content()
    self._can_pickup = picked_object is PhysicsProp


func _move(delta: float) -> void:
    if not is_on_floor():
        var gravity_factor := 1.0
        if 0.0 > self._vertical_velocity.y:
            gravity_factor = self.downward_gravity_factor
        self._vertical_velocity += gravity_factor * get_gravity() * delta

    var motion_dir := self._get_motion()
    var motion := self.transform.basis * Vector3(motion_dir.x, 0, motion_dir.y)
    if motion.is_zero_approx():
        self._horizontal_velocity = self._horizontal_velocity.lerp(
            Vector3.ZERO, self.deceleration * delta
        )
    else:
        var accel_value := self.acceleration
        if 0.0 > motion.normalized().dot(self._horizontal_velocity.normalized()):
            accel_value = self.deceleration
        self._horizontal_velocity += motion * accel_value * delta

    if self._horizontal_velocity.length() > self.max_speed:
        self._horizontal_velocity *= self.max_speed / self._horizontal_velocity.length()

    self.velocity = self._horizontal_velocity + self._vertical_velocity

    self.move_and_slide()

    self._horizontal_velocity = Plane(Vector3.UP).project(self.velocity)
    self._vertical_velocity = self.velocity.project(Vector3.UP)


func _get_motion() -> Vector2:
    if not self._is_player_controlling:
        return Vector2.ZERO
    return Input.get_vector("move left", "move right", "move forward", "move backward").normalized()


func _drag_held_object(_delta: float) -> void:
    if not self._held_prop:
        return

    var position_delta := self._hold_point.global_position - self._held_prop.global_position
    self._held_prop.desired_linear_velocity = position_delta * self.hold_drag_force


func _adjust_camera_height(delta: float) -> void:
    var target_pos := $upright_pos.position as Vector3
    if self._is_crouched:
        target_pos = $crouched_pos.position
    self._camera.position = self._camera.position.lerp(target_pos, delta * 5.0)


func _on_game_state_changed(new_state: Game.State) -> void:
    self._is_player_controlling = new_state == Game.State.PLAYING
