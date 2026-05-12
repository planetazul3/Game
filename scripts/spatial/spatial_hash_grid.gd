extends Node
# SpatialHashGrid: Optimized, deterministic spatial partitioning

@export var cell_size: float = 10.0

# _grid[cell_coords] = [entity1, entity2, ...]
var _grid: Dictionary = {}
# _entity_cells[entity] = cell_coords
var _entity_cells: Dictionary = {}

func insert_entity(entity: Node, position: Vector3) -> void:
	if not is_instance_valid(entity): return
	
	var cell = _get_cell_coords(position)
	if not _grid.has(cell):
		_grid[cell] = []
	
	_grid[cell].append(entity)
	_entity_cells[entity] = cell

func remove_entity(entity: Node) -> void:
	if not _entity_cells.has(entity): return
	
	var cell = _entity_cells[entity]
	if _grid.has(cell):
		_grid[cell].erase(entity)
		if _grid[cell].is_empty():
			_grid.erase(cell)
	
	_entity_cells.erase(entity)

func update_entity(entity: Node, position: Vector3) -> void:
	if not is_instance_valid(entity): return
	
	var new_cell = _get_cell_coords(position)
	var old_cell = _entity_cells.get(entity, Vector2i(-999999, -999999))
	
	if new_cell != old_cell:
		remove_entity(entity)
		insert_entity(entity, position)

func query_radius(position: Vector3, radius: float) -> Array[Node]:
	var result: Array[Node] = []
	var min_cell = _get_cell_coords(position - Vector3(radius, 0, radius))
	var max_cell = _get_cell_coords(position + Vector3(radius, 0, radius))
	
	var r_sq = radius * radius
	
	for x in range(min_cell.x, max_cell.x + 1):
		for y in range(min_cell.y, max_cell.y + 1):
			var cell = Vector2i(x, y)
			if _grid.has(cell):
				for entity in _grid[cell]:
					if not is_instance_valid(entity): continue
					var dist_sq = position.distance_squared_to(entity.global_position)
					if dist_sq <= r_sq:
						result.append(entity)
	
	return result

func query_cell(cell_coords: Vector2i) -> Array[Node]:
	return _grid.get(cell_coords, [])

func _get_cell_coords(position: Vector3) -> Vector2i:
	return Vector2i(
		floor(position.x / cell_size),
		floor(position.z / cell_size)
	)

func clear() -> void:
	_grid.clear()
	_entity_cells.clear()
