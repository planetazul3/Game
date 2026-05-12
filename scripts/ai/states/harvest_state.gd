extends AIState
class_name HarvestState

var target_resource: Node

func enter(msg: Dictionary = {}) -> void:
	if msg.has("target_resource"):
		target_resource = msg["target_resource"]
	
	var gather_comp = unit.get("gatherer_component")
	if gather_comp:
		gather_comp.target_resource = target_resource

func tick(_delta: float) -> void:
	if not is_instance_valid(target_resource):
		fsm.change_state("Idle")
		return
	
	# Logic for movement to resource could be added here or via a sub-state
	# For simplicity, we assume ResourceSystem handles the gathering if in range

func handle_command(type: String, target: Variant) -> void:
	if type == "harvest":
		enter({"target_resource": target})
	else:
		fsm.change_state("Idle")
		fsm.handle_command(type, target)
