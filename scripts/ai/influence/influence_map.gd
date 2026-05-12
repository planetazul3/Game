extends RefCounted
class_name InfluenceMap
# InfluenceMap: Base class for spatial reasoning grids

var grid: PackedFloat32Array
var width: int
var height: int
var cell_size: float

func _init(p_width: int, p_height: int, p_cell_size: float) -> void:
	width = p_width
	height = p_height
	cell_size = p_cell_size
	grid.resize(width * height)
	grid.fill(0.0)

func add_influence(world_pos: Vector3, value: float, radius: float) -> void:
	var gp = world_to_grid(world_pos)
	var r_cells = int(radius / cell_size)
	
	for dy in range(-r_cells, r_cells + 1):
		for dx in range(-r_cells, r_cells + 1):
			var nx = gp.x + dx
			var ny = gp.y + dy
			if nx < 0 or nx >= width or ny < 0 or ny >= height: continue
			
			var dist_sq = dx * dx + dy * dy
			var r_sq = r_cells * r_cells
			if dist_sq <= r_sq:
				# Simple linear decay
				var falloff = 1.0 - (sqrt(dist_sq) / r_cells)
				grid[ny * width + nx] += value * falloff

func get_influence(world_pos: Vector3) -> float:
	var gp = world_to_grid(world_pos)
	if gp.x >= 0 and gp.x < width and gp.y >= 0 and gp.y < height:
		return grid[gp.y * width + gp.x]
	return 0.0

func world_to_grid(world_pos: Vector3) -> Vector2i:
	return Vector2i(
		floor(world_pos.x / cell_size),
		floor(world_pos.z / cell_size)
	)

func clear() -> void:
	grid.fill(0.0)
