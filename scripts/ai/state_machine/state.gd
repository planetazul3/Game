extends RefCounted
class_name AIState

var unit: Node
var fsm: RefCounted # AIStateMachine

func _init(p_unit: Node, p_fsm: RefCounted) -> void:
	unit = p_unit
	fsm = p_fsm

func enter(_msg: Dictionary = {}) -> void:
	pass

func exit() -> void:
	pass

func tick(_delta: float) -> void:
	pass

func handle_command(_type: String, _target: Variant) -> void:
	pass
