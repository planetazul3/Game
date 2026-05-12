extends Node
class_name AISystem

var faction_ais: Dictionary = {} # faction_id -> FactionAI

func tick(delta: float) -> void:
	var sim_manager = get_parent().get_node_or_null("SimulationManager")
	var current_tick = sim_manager.current_tick if sim_manager else 0
	
	# 1. Update Strategic Layer
	for faction_id in faction_ais:
		faction_ais[faction_id].tick(current_tick, delta)
		
	# 2. Update Tactical Layer (Unit FSMs)
	var entities = EntityManager.get_nodes_with_component("AIComponent")
	for entity in entities:
		var ai_comp = entity.get("ai_component")
		if ai_comp and ai_comp.state_machine:
			ai_comp.state_machine.tick(delta)

func register_faction_ai(faction_id: int) -> void:
	if not faction_ais.has(faction_id):
		var ai_script = load("res://scripts/ai/strategic/faction_ai.gd")
		var ai = ai_script.new()
		ai.faction_id = faction_id
		faction_ais[faction_id] = ai
		add_child(ai)

func handle_unit_command(unit: Node, type: String, target: Variant) -> void:
	var ai_comp = unit.get("ai_component")
	if ai_comp and ai_comp.state_machine:
		ai_comp.state_machine.handle_command(type, target)
