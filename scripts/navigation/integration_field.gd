extends RefCounted
class_name IntegrationField
# IntegrationField: Dijkstra-based distance field from a target cell

var grid: PackedInt32Array
var width: int
var height: int

func _init(p_width: int, p_height: int) -> void:
	width = p_width
	height = p_height
	grid.resize(width * height)
	grid.fill(65535) # "Infinity"

func generate(target_x: int, target_y: int, cost_field) -> void:
	grid.fill(65535)
	
	var start_idx = target_y * width + target_x
	if start_idx < 0 or start_idx >= grid.size(): return
	
	grid[start_idx] = 0
	
	var queue: Array[int] = [start_idx]
	var head = 0
	
	while head < queue.size():
		var current_idx = queue[head]
		head += 1
		
		var cx = current_idx % width
		var cy = current_idx / width
		var current_cost = grid[current_idx]
		
		# Neighbors (4-way for simplicity, 8-way is better)
		var neighbors = [
			Vector2i(cx + 1, cy), Vector2i(cx - 1, cy),
			Vector2i(cx, cy + 1), Vector2i(cx, cy - 1)
		]
		
		for n in neighbors:
			if n.x < 0 or n.x >= width or n.y < 0 or n.y >= height: continue
			
			var n_cost = cost_field.get_cost(n.x, n.y)
			if n_cost == 255: continue # Blocked
			
			var new_dist = current_cost + n_cost
			var n_idx = n.y * width + n.x
			
			if new_dist < grid[n_idx]:
				grid[n_idx] = new_dist
				queue.append(n_idx)
