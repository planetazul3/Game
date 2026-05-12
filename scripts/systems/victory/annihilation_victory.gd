extends VictoryCondition
class_name AnnihilationVictory

var _started_with_multiple_factions := false

func evaluate() -> void:
	var factions_alive = {}
	var scene_units = get_tree().get_nodes_in_group("selectable")

	for sel in scene_units:
		var entity = sel.get_parent()
		if not is_instance_valid(entity): continue

		var vis_comp = entity.get_node_or_null("VisibilityComponent")
		if vis_comp:
			factions_alive[vis_comp.faction_id] = true

	if not _started_with_multiple_factions:
		if factions_alive.size() > 1:
			_started_with_multiple_factions = true
		return

	# If only one faction remains after having started with multiple
	if factions_alive.size() == 1:
		var winner = factions_alive.keys()[0]
		condition_met.emit(winner, "Annihilation")
