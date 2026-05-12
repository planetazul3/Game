extends Node
# WorldGenerator: Orchestrates deterministic procedural generation

@export var seed_value: int = 12345
@export var world_size: Vector2 = Vector2(1000, 1000)
@export var sector_count: int = 16

var _rng: RandomNumberGenerator

func generate_world(p_seed: int) -> void:
	seed_value = p_seed
	_rng = RandomNumberGenerator.new()
	_rng.seed = seed_value
	
	print("WorldGenerator: Generating world with seed ", seed_value)
	
	# 1. Generate Biomes/Terrain
	_generate_biomes()
	
	# 2. Distribute Resources
	_distribute_resources()
	
	# 3. Spawn Structures/Factions
	_spawn_structures()

func _generate_biomes() -> void:
	# Use deterministic noise (FastNoiseLite with seed)
	var noise = FastNoiseLite.new()
	noise.seed = seed_value
	noise.frequency = 0.01
	
	# For simplicity, we'd generate a heightmap or biome grid here
	pass

func _distribute_resources() -> void:
	# Deterministic resource placement
	for i in range(100):
		var pos = Vector3(_rng.randf_range(0, world_size.x), 0, _rng.randf_range(0, world_size.y))
		# EntityFactory.spawn_entity("ResourceNode", pos)
		pass

func _spawn_structures() -> void:
	# Balanced spawn points
	pass
