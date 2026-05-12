extends AIState
class_name DeadState

func enter(_msg: Dictionary = {}) -> void:
	# Disable all components
	var move_comp = unit.get("movement_component")
	if move_comp:
		move_comp.has_target = false
	
	var combat_comp = unit.get("combat_component")
	if combat_comp:
		combat_comp.target = null
	
	# Trigger cleanup through EventBus
	EventBus.unit_died.emit(unit)

func tick(_delta: float) -> void:
	# Dead units don't tick
	pass

func handle_command(_type: String, _target: Variant) -> void:
	# Dead units don't follow commands
	pass
