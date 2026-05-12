extends RefCounted
class_name ThreatAnalyzer
# ThreatAnalyzer: Evaluates map visibility and enemy positions

var faction_id: int
var threats: Dictionary = {} # position -> threat_score

func update_analysis() -> void:
	threats.clear()
	# 1. Query all enemy units via ComponentRegistry
	# For simplicity, we'll just check all units not in our faction
	var all_move_comps = ComponentRegistry.get_components_by_type("MovementComponent")
	for move_comp in all_move_comps:
		var entity_id = ComponentRegistry.get_owner_id(move_comp)
		var entity = EntityManager.get_entity(entity_id)
		if not is_instance_valid(entity): continue
		
		# Check faction (assume visibility_component has it)
		var vis_comp = entity.get("visibility_component")
		if vis_comp and vis_comp.faction_id != faction_id:
			# If visible to us, it's a threat
			if vis_comp.current_state == 2: # VISIBLE
				_record_threat(entity.global_position, 10.0) # Base threat

func _record_threat(pos: Vector3, score: float) -> void:
	var grid_pos = Vector2i(int(pos.x / 10), int(pos.z / 10))
	threats[grid_pos] = threats.get(grid_pos, 0.0) + score

func get_threat_at(pos: Vector3) -> float:
	var grid_pos = Vector2i(int(pos.x / 10), int(pos.z / 10))
	return threats.get(grid_pos, 0.0)
