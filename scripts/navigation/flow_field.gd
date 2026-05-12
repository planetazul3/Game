extends RefCounted
class_name FlowField
# FlowField: Vector field derived from IntegrationField for unit steering

var grid: Array[Vector2] # x,z direction
var width: int
var height: int

func _init(p_width: int, p_height: int) -> void:
	width = p_width
	height = p_height
	grid.resize(width * height)
	grid.fill(Vector2.ZERO)

func generate(integration_field) -> void:
	for y in range(height):
		for x in range(width):
			var idx = y * width + x
			var best_neighbor = Vector2i(x, y)
			var min_dist = integration_field.grid[idx]
			
			if min_dist == 65535:
				grid[idx] = Vector2.ZERO
				continue
				
			# 8-way check for steepest descent
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					if dx == 0 and dy == 0: continue
					var nx = x + dx
					var ny = y + dy
					if nx < 0 or nx >= width or ny < 0 or ny >= height: continue
					
					var n_dist = integration_field.grid[ny * width + nx]
					if n_dist < min_dist:
						min_dist = n_dist
						best_neighbor = Vector2i(nx, ny)
			
			if best_neighbor != Vector2i(x, y):
				var dir = Vector2(best_neighbor.x - x, best_neighbor.y - y).normalized()
				grid[idx] = dir
			else:
				grid[idx] = Vector2.ZERO

func get_direction(x: int, y: int) -> Vector2:
	if x >= 0 and x < width and y >= 0 and y < height:
		return grid[y * width + x]
	return Vector2.ZERO
