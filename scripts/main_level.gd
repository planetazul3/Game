extends Node3D

func _ready() -> void:
	var sim_manager = get_node_or_null("Systems/SimulationManager")
	if sim_manager:
		var annihilation = AnnihilationVictory.new()
		sim_manager.register_victory_condition(annihilation)

		var resource_vic = ResourceVictory.new()
		sim_manager.register_victory_condition(resource_vic)

	# Spawn initial units for testing
	var soldier_def = load("res://data/units/soldier.tres")
	if soldier_def:
		# Faction 0 (Player)
		EntityFactory.spawn_unit(soldier_def, Vector3(-5, 0, 0), 0)
		EntityFactory.spawn_unit(soldier_def, Vector3(-3, 0, 2), 0)
		
		# Faction 1 (Enemy)
		EntityFactory.spawn_unit(soldier_def, Vector3(5, 0, 0), 1)
		EntityFactory.spawn_unit(soldier_def, Vector3(3, 0, -2), 1)
