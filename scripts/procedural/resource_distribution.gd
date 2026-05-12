extends RefCounted
class_name ResourceDistribution
# ResourceDistribution: Handles balanced and deterministic resource spawning

func distribute_in_sector(sector_coords: Vector2i, rng: RandomNumberGenerator) -> Array:
	var nodes = []
	var count = rng.randi_range(2, 5)
	
	for i in range(count):
		var local_pos = Vector2(rng.randf_range(0, 250), rng.randf_range(0, 250))
		nodes.append({
			"type": "ORE_NODE",
			"position": local_pos,
			"amount": rng.randi_range(1000, 5000)
		})
		
	return nodes
