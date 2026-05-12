extends AIState
class_name AttackState

var target_entity: Node

func enter(msg: Dictionary = {}) -> void:
	if msg.has("target_entity"):
		target_entity = msg["target_entity"]
	
	var combat_comp = unit.get("combat_component")
	if combat_comp:
		combat_comp.target = target_entity

func tick(_delta: float) -> void:
	if not is_instance_valid(target_entity):
		fsm.change_state("idle")
		return
	
	var health = target_entity.get("health_component")
	if not health or health.current_health <= 0:
		fsm.change_state("idle")
		return

func handle_command(type: String, target: Variant) -> void:
	if type == "attack":
		enter({"target_entity": target})
	else:
		fsm.change_state("idle")
		fsm.handle_command(type, target)
