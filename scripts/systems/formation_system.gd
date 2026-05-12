extends Node
# FormationSystem: Deterministic unit positioning for groups

enum FormationType { BOX, LINE, WEDGE }

@export var default_spacing: float = 2.0

func get_formation_offsets(units: Array[Node], type: FormationType, spacing: float = 2.0) -> Dictionary:
	var offsets = {}
	var count = units.size()
	if count == 0: return offsets
	
	# 1. Sort units by entity_id to ensure deterministic slot assignment
	var sorted_units = units.duplicate()
	sorted_units.sort_custom(func(a, b): 
		return a.get_meta("entity_id") < b.get_meta("entity_id")
	)
	
	# 2. Calculate offsets
	for i in range(count):
		var offset = Vector3.ZERO
		match type:
			FormationType.BOX:
				offset = _calculate_box_offset(i, count, spacing)
			FormationType.LINE:
				offset = _calculate_line_offset(i, count, spacing)
			FormationType.WEDGE:
				offset = _calculate_wedge_offset(i, count, spacing)
		
		offsets[sorted_units[i]] = offset
		
	return offsets

func _calculate_box_offset(index: int, total: int, spacing: float) -> Vector3:
	var columns = int(ceil(sqrt(total)))
	var row = index / columns
	var col = index % columns
	
	# Center the formation
	var offset_x = col * spacing - ((columns - 1) * spacing / 2.0)
	var offset_z = row * spacing - ((int(ceil(float(total) / columns)) - 1) * spacing / 2.0)
	
	return Vector3(offset_x, 0, offset_z)

func _calculate_line_offset(index: int, total: int, spacing: float) -> Vector3:
	# Center the line
	var offset_x = index * spacing - ((total - 1) * spacing / 2.0)
	return Vector3(offset_x, 0, 0)

func _calculate_wedge_offset(index: int, total: int, spacing: float) -> Vector3:
	# Wedge: 1 in front, 2 in second row, 3 in third, etc.
	# Or simpler: V-shape
	var row = 0
	var count_in_rows = 0
	while count_in_rows + (row + 1) <= index:
		count_in_rows += (row + 1)
		row += 1
	
	var pos_in_row = index - count_in_rows
	var row_width = row + 1
	var offset_x = pos_in_row * spacing - ((row_width - 1) * spacing / 2.0)
	var offset_z = row * spacing
	
	return Vector3(offset_x, 0, offset_z)

func tick(delta: float) -> void:
	var move_components = ComponentRegistry.get_components_by_type("MovementComponent")
	for move_comp in move_components:
		var entity_id = ComponentRegistry.get_owner_id(move_comp)
		var entity = EntityManager.get_entity(entity_id)
		if not is_instance_valid(entity): continue
		
		_apply_separation(entity, move_comp, delta)

func _apply_separation(entity: Node, move_comp: MovementComponent, delta: float) -> void:
	# Query nearby entities to avoid overlap
	var neighbors = SpatialGrid.query_radius(entity.global_position, default_spacing)
	var separation_force = Vector3.ZERO
	
	for neighbor in neighbors:
		if neighbor == entity: continue
		
		var dist = entity.global_position.distance_to(neighbor.global_position)
		if dist < default_spacing:
			var push_dir = neighbor.global_position.direction_to(entity.global_position)
			# Stronger push the closer they are
			separation_force += push_dir * (default_spacing - dist)
	
	if separation_force.length() > 0:
		if entity is CharacterBody3D:
			# Apply soft separation to velocity
			entity.velocity += separation_force * delta * 50.0
