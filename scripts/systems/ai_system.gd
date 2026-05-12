extends Node
class_name AISystem

func tick(delta: float) -> void:
	var entities = EntityManager.get_nodes_with_component("AIComponent")
	for entity in entities:
		var ai_comp = entity.get("ai_component")
		if ai_comp and ai_comp.state_machine:
			ai_comp.state_machine.tick(delta)

func handle_unit_command(unit: Node, type: String, target: Variant) -> void:
	var ai_comp = unit.get("ai_component")
	if ai_comp and ai_comp.state_machine:
		ai_comp.state_machine.handle_command(type, target)
