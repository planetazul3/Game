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
	var dir = Vector3.ZERO
	
	if move_comp.current_flow_field:
		var ff_mgr = get_parent().get_node_or_null("FlowFieldManager")
		if ff_mgr:
			var grid_pos = ff_mgr.world_to_grid(move_comp.simulation_position)
			var flow_dir = move_comp.current_flow_field.get_direction(grid_pos.x, grid_pos.y)
			dir = Vector3(flow_dir.x, 0, flow_dir.y)
			
			# Arrival check
			var dist_to_target = move_comp.simulation_position.distance_to(move_comp.target_position)
			if dist_to_target < arrival_tolerance:
				move_comp.has_target = false
				return
	
	if dir.is_zero_approx():
		# Fallback or stationary
		move_comp.has_target = false
		return

	var intended_vel = dir * move_comp.move_speed
	
	# Deterministic Integration
	var next_pos = TransformIntegrator.integrate(move_comp.simulation_position, intended_vel, delta)
	
	# Deterministic Collision (Circle)
	var neighbors = SpatialGrid.query_radius(next_pos, 2.0)
	next_pos = TransformIntegrator.resolve_collisions(entity, next_pos, 0.5, neighbors)
	
	move_comp.simulation_position = next_pos
	entity.global_position = next_pos 
	SpatialGrid.update_entity(entity, next_pos)

	if intended_vel.length() > 0.1:
		var look_target = next_pos + intended_vel
		entity.look_at(Vector3(look_target.x, next_pos.y, look_target.z), Vector3.UP)

func _on_command_issued(units: Array[Node], command_type: String, target: Variant) -> void:
	if command_type == "move":
		var target_pos = target as Vector3
		var ff_mgr = get_parent().get_node_or_null("FlowFieldManager")
		var shared_ff = null
		if ff_mgr:
			shared_ff = ff_mgr.get_flow_field(target_pos)
		
		for unit in units:
			if not is_instance_valid(unit): continue
			var move_comp = unit.get("movement_component") as MovementComponent
			if move_comp:
				move_comp.target_position = target_pos
				move_comp.has_target = true
				move_comp.is_path_ready = true
				move_comp.current_flow_field = shared_ff
				
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

