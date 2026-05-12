extends AIState
class_name IdleState

func enter(_msg: Dictionary = {}) -> void:
	# Stop all current behaviors
	var move_comp = unit.get("movement_component")
	if move_comp:
		move_comp.has_target = false
	
	var combat_comp = unit.get("combat_component")
	if combat_comp:
		combat_comp.target = null

func tick(_delta: float) -> void:
	# Idle could evaluate surrounding targets if aggressive
	pass

func handle_command(type: String, target: Variant) -> void:
	match type:
		"move":
			fsm.change_state("move", {"target_position": target})
		"attack":
			fsm.change_state("combat", {"target_entity": target})
		"harvest":
			fsm.change_state("harvest", {"target_resource": target})
