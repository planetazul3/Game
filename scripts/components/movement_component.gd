extends RefCounted
class_name MovementComponent

var target_position: Vector3 = Vector3.ZERO
var has_target: bool = false
var move_speed: float = 5.0
var acceleration: float = 10.0
var path: PackedVector3Array = []
var path_index: int = 0
var is_path_ready: bool = false
