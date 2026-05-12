extends Node
class_name MovementSystem

var entities_to_move: Array[Node] = []
var pathfinding_throttle_timer: float = 0.0
var pathfinding_interval: float = 0.2
var arrival_tolerance: float = 1.0

func _ready() -> void:
	EventBus.safe_connect("command_issued", _on_command_issued)

func simulation_tick(delta: float) -> void:
	pathfinding_throttle_timer -= delta
	var can_pathfind = pathfinding_throttle_timer <= 0
	if can_pathfind:
		pathfinding_throttle_timer = pathfinding_interval

	for i in range(entities_to_move.size() - 1, -1, -1):
		var entity = entities_to_move[i]
		if not is_instance_valid(entity):
			entities_to_move.remove_at(i)
			continue

		var move_comp = entity.get_node_or_null("MovementComponent")
		var nav_agent = entity.get_node_or_null("NavigationAgent3D")
		if not move_comp or not nav_agent:
			continue

		if not move_comp.has_target:
			continue

		var dist_to_target = entity.global_position.distance_to(move_comp.target_position)
		if dist_to_target <= arrival_tolerance:
			move_comp.has_target = false
			if entity is CharacterBody3D:
				entity.velocity = Vector3.ZERO
			continue

		if can_pathfind:
			nav_agent.target_position = move_comp.target_position

		if not nav_agent.is_navigation_finished():
			var next_pos = nav_agent.get_next_path_position()
			var dir = entity.global_position.direction_to(next_pos)

			if entity is CharacterBody3D:
				# Stuck recovery basic: if velocity is tiny but we have a target, apply slight jitter
				var intended_vel = dir * move_comp.move_speed

				# Simple collision avoidance / soft repathing proxy
				entity.velocity = entity.velocity.lerp(intended_vel, delta * move_comp.acceleration)
				entity.move_and_slide()

				if entity.velocity.length() > 0.1:
					var look_target = entity.global_position + entity.velocity
					entity.look_at(Vector3(look_target.x, entity.global_position.y, look_target.z), Vector3.UP)
		else:
			move_comp.has_target = false

func _on_command_issued(units: Array[Node], command_type: String, target: Variant) -> void:
	if command_type == "move":
		var target_pos = target as Vector3
		var formation_offset := Vector3.ZERO
		var spacing := 2.0
		var columns := int(ceil(sqrt(units.size())))

		for i in range(units.size()):
			var unit = units[i]
			if not is_instance_valid(unit): continue

			var move_comp = unit.get_node_or_null("MovementComponent")
			if move_comp:
				if units.size() > 1:
					var row = i / columns
					var col = i % columns
					formation_offset = Vector3(col * spacing - (columns * spacing / 2.0), 0, row * spacing - (columns * spacing / 2.0))

				move_comp.target_position = target_pos + formation_offset
				move_comp.has_target = true
				if unit not in entities_to_move:
					entities_to_move.append(unit)
