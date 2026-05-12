extends AIState
class_name MoveState

var target_position: Vector3 = Vector3.ZERO
var arrival_tolerance: float = 1.5

func enter(msg: Dictionary = {}) -> void:
	if msg.has("target_position"):
		target_position = msg["target_position"]
	
	var move_comp = unit.get("movement_component")
	if move_comp:
		move_comp.target_position = target_position
		move_comp.has_target = true

func tick(_delta: float) -> void:
	var move_comp = unit.get("movement_component")
	if not move_comp or not move_comp.has_target:
		fsm.change_state("idle")
		return
	
	var dist = unit.global_position.distance_to(target_position)
	if dist <= arrival_tolerance:
		move_comp.has_target = false
		fsm.change_state("idle")

func handle_command(type: String, target: Variant) -> void:
	if type == "move":
		enter({"target_position": target})
	else:
		# Interrupt movement for other commands
		fsm.change_state("idle")
		fsm.handle_command(type, target)
