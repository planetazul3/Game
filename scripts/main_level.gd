extends Node3D

func _ready() -> void:
	_apply_visual_polish()
	
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

func _apply_visual_polish() -> void:
	# 1. Apply Sci-Fi Ground Material
	var ground = get_node_or_null("World/Ground")
	if ground:
		var mat = StandardMaterial3D.new()
		var tex = load("res://assets/textures/ground_sci_fi.jpg")
		if tex:
			mat.albedo_texture = tex
			mat.uv1_scale = Vector3(20, 20, 20) # Repeat texture for detail
			mat.roughness = 0.4
			mat.metallic = 0.6
		ground.material_override = mat
	
	# 2. Environmental Lighting (Simple pass)
	var env = get_node_or_null("World/WorldEnvironment")
	if env and env.environment:
		env.environment.background_mode = Environment.BG_COLOR
		env.environment.background_color = Color(0.02, 0.02, 0.05)
		env.environment.glow_enabled = true
		env.environment.glow_intensity = 0.8
