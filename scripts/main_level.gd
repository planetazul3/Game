extends Node3D

func _ready() -> void:
	var sim_manager = get_node_or_null("Systems/SimulationManager")
	if sim_manager:
		var annihilation = AnnihilationVictory.new()
		add_child(annihilation)
		sim_manager.register_victory_condition(annihilation)

		var resource_vic = ResourceVictory.new()
		add_child(resource_vic)
		sim_manager.register_victory_condition(resource_vic)
