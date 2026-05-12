extends RefCounted
class_name MovementComponent

var simulation_position: Vector3 = Vector3.ZERO
var target_position: Vector3 = Vector3.ZERO
var has_target: bool = false
var move_speed: float = 5.0
var acceleration: float = 10.0
var path: PackedVector3Array = []
var path_index: int = 0
var is_path_ready: bool = false
var current_flow_field: RefCounted = null # FlowField

func save_state() -> Dictionary:
	return {
		"target_position": [target_position.x, target_position.y, target_position.z],
		"has_target": has_target,
		"move_speed": move_speed,
		"acceleration": acceleration,
		"path": Array(path), # PackedVector3Array to Array for JSON
		"path_index": path_index,
		"is_path_ready": is_path_ready
	}

func load_state(data: Dictionary) -> void:
	target_position = Vector3(data.target_position[0], data.target_position[1], data.target_position[2])
	has_target = data.has_target
	move_speed = data.move_speed
	acceleration = data.acceleration
	path = PackedVector3Array(data.path)
	path_index = data.path_index
	is_path_ready = data.is_path_ready
