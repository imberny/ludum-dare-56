class_name PhysicsProp extends RigidBody3D

var desired_linear_velocity: Vector3

var _is_grabbed := false


func grab() -> void:
	self.sleeping = false
	self._is_grabbed = true


func drop() -> void:
	self._is_grabbed = false


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if self._is_grabbed:
		state.linear_velocity = self.desired_linear_velocity
