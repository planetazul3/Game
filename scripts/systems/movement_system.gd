extends Node
class_name MovementSystem

var entities_to_move: Array[Node] = []
var path_request_queue: Array[int] = [] # entity_ids
var max_path_requests_per_tick: int = 10
var arrival_tolerance: float = 0.5
var waypoint_tolerance: float = 0.2

func _ready() -> void:
	EventBus.safe_connect("command_issued", _on_command_issued)

func tick(delta: float) -> void:
	# 1. Process Path Requests (Throttled)
	_process_path_requests()

	# 2. Update Movement
	for i in range(entities_to_move.size() - 1, -1, -1):
		var entity = entities_to_move[i]
		if not is_instance_valid(entity):
			entities_to_move.remove_at(i)
			continue

		var move_comp = entity.get("movement_component") as MovementComponent
		if not move_comp or not move_comp.has_target or not move_comp.is_path_ready:
			continue

		_follow_path(entity, move_comp, delta)

func _process_path_requests() -> void:
	var processed = 0
	while path_request_queue.size() > 0 and processed < max_path_requests_per_tick:
		var entity_id = path_request_queue.pop_front()
		var entity = EntityManager.get_entity(entity_id)
		if not is_instance_valid(entity): continue
		
		var move_comp = entity.get("movement_component") as MovementComponent
		if not move_comp: continue
		
		var map = get_tree().root.get_world_3d().navigation_map
		var path = NavigationServer3D.map_get_path(map, entity.global_position, move_comp.target_position, true)
		
		move_comp.path = path
		move_comp.path_index = 0
		move_comp.is_path_ready = true
		processed += 1

func _follow_path(entity: Node, move_comp: MovementComponent, delta: float) -> void:
	if move_comp.path_index >= move_comp.path.size():
		move_comp.has_target = false
		return

	var target_waypoint = move_comp.path[move_comp.path_index]
	var pos = entity.global_position
	var dir = pos.direction_to(target_waypoint)
	var dist = pos.distance_to(target_waypoint)

	# If reached waypoint, move to next
	if dist <= waypoint_tolerance:
		move_comp.path_index += 1
		if move_comp.path_index >= move_comp.path.size():
			move_comp.has_target = false
			if entity is CharacterBody3D:
				entity.velocity = Vector3.ZERO
			return
		# Recalculate for next waypoint in same tick if needed? 
		# For simplicity, just update target for next tick
		target_waypoint = move_comp.path[move_comp.path_index]
		dir = pos.direction_to(target_waypoint)

	if entity is CharacterBody3D:
		var intended_vel = dir * move_comp.move_speed
		entity.velocity = entity.velocity.lerp(intended_vel, delta * move_comp.acceleration)
		entity.move_and_slide()
		SpatialGrid.update_entity(entity, entity.global_position)

		if entity.velocity.length() > 0.1:
			var look_target = entity.global_position + entity.velocity
			entity.look_at(Vector3(look_target.x, entity.global_position.y, look_target.z), Vector3.UP)

func _on_command_issued(units: Array[Node], command_type: String, target: Variant) -> void:
	if command_type == "move":
		var target_pos = target as Vector3
		
		var formation_sys = get_parent().get_node_or_null("FormationSystem")
		var offsets = {}
		if formation_sys:
			offsets = formation_sys.get_formation_offsets(units, 0) # BOX = 0
		
		for unit in units:
			if not is_instance_valid(unit): continue
			var move_comp = unit.get("movement_component") as MovementComponent
			if move_comp:
				var offset = offsets.get(unit, Vector3.ZERO)
				move_comp.target_position = target_pos + offset
				move_comp.has_target = true
				move_comp.is_path_ready = false
				
				var id = unit.get_meta("entity_id")
				if id not in path_request_queue:
					path_request_queue.append(id)
				if unit not in entities_to_move:
					entities_to_move.append(unit)

				if unit not in entities_to_move:
					entities_to_move.append(unit)

func save_state() -> Dictionary:
	var entity_ids = []
	for entity in entities_to_move:
		if is_instance_valid(entity):
			entity_ids.append(entity.get_meta("entity_id"))
	
	return {
		"entities_to_move": entity_ids,
		"path_request_queue": path_request_queue.duplicate()
	}

func load_state(state: Dictionary) -> void:
	entities_to_move.clear()
	for id in state.entities_to_move:
		var entity = EntityManager.get_entity(id)
		if entity: entities_to_move.append(entity)
	
	path_request_queue = Array(state.path_request_queue)

