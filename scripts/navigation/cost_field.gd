extends RefCounted
class_name CostField
# CostField: Gridded representation of terrain traversal costs

var grid: PackedByteArray
var width: int
var height: int
var cell_size: float

func _init(p_width: int, p_height: int, p_cell_size: float) -> void:
	width = p_width
	height = p_height
	cell_size = p_cell_size
	grid.resize(width * height)
	grid.fill(1) # Default cost

func set_cost(x: int, y: int, cost: int) -> void:
	if x >= 0 and x < width and y >= 0 and y < height:
		grid[y * width + x] = cost

func get_cost(x: int, y: int) -> int:
	if x >= 0 and x < width and y >= 0 and y < height:
		return grid[y * width + x]
	return 255 # Obstacle

func world_to_grid(world_pos: Vector3) -> Vector2i:
	return Vector2i(
		floor(world_pos.x / cell_size),
		floor(world_pos.z / cell_size)
	)
