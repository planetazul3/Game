extends RefCounted
class_name SectorGenerator
# SectorGenerator: Handles chunked world generation and strategic layout

var sector_size: float = 250.0

func generate_sector(coords: Vector2i, seed: int) -> Dictionary:
	var rng = RandomNumberGenerator.new()
	# Combinatorial seed for deterministic chunking
	rng.seed = hash(str(coords) + str(seed))
	
	var sector_data = {
		"coords": coords,
		"features": [],
		"hazard_level": rng.randf()
	}
	
	# Determine if sector has a chokepoint or objective
	if rng.randf() > 0.8:
		sector_data.features.append("STRATEGIC_CHOKEPOINT")
		
	return sector_data
