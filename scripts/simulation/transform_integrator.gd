extends Node
# TransformIntegrator: Handles deterministic position updates and collision resolution

static func integrate(current_pos: Vector3, velocity: Vector3, delta: float) -> Vector3:
	return current_pos + (velocity * delta)

static func resolve_collisions(entity: Node, pos: Vector3, radius: float, neighbors: Array[Node]) -> Vector3:
	var final_pos = pos
	
	# Simple circle-circle resolution in fixed order
	# Neighbors should be sorted by entity_id for determinism
	var sorted_neighbors = neighbors.duplicate()
	sorted_neighbors.sort_custom(func(a, b): return a.get_meta("entity_id") < b.get_meta("entity_id"))
	
	for neighbor in sorted_neighbors:
		if neighbor == entity: continue
		
		# Assuming neighbors also have a radius (could be in a component)
		var neighbor_radius = 0.5 # Default
		var min_dist = radius + neighbor_radius
		var dist_sq = final_pos.distance_squared_to(neighbor.global_position)
		
		if dist_sq < min_dist * min_dist:
			var dist = sqrt(dist_sq)
			if dist < 0.001: # Overlap exactly
				final_pos += Vector3(0.01, 0, 0) # Nudge deterministically
			else:
				var push_dir = (final_pos - neighbor.global_position) / dist
				var overlap = min_dist - dist
				final_pos += push_dir * overlap # Full resolution for simplicity
				
	return final_pos
