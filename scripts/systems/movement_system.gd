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
	var units = get_tree().get_nodes_in_group("units")
	for unit in units:
		if not is_instance_valid(unit): continue
		var move_comp = unit.get("movement_component")
		if not move_comp or not move_comp.has_target:
			continue
		
		_move_unit(unit, move_comp, delta)

func _move_unit(unit: Node, move_comp: MovementComponent, delta: float) -> void:
	var current_pos = unit.global_position
	var target_pos = move_comp.target_position
	
	# 1. Calculate direction
	var dir = Vector3.ZERO
	
	if move_comp.current_flow_field:
		var ff_mgr = get_parent().get_node_or_null("FlowFieldManager")
		if ff_mgr:
			var grid_pos = ff_mgr.world_to_grid(current_pos)
			var flow_dir = move_comp.current_flow_field.get_direction(grid_pos.x, grid_pos.y)
			dir = Vector3(flow_dir.x, 0, flow_dir.y)
	
	if dir.is_zero_approx():
		# Use direct steering toward target as fallback
		dir = (target_pos - current_pos).normalized()
		dir.y = 0
	
	# 2. Check for arrival
	var dist = current_pos.distance_to(target_pos)
	if dist < arrival_tolerance:
		move_comp.has_target = false
		return
		
	# 3. Calculate velocity
	var intended_vel = dir * move_comp.move_speed
	
	# 4. Integrate position
	var next_pos = current_pos + intended_vel * delta
	
	# 5. Simple Collision Avoidance (Avoid overlapping)
	var neighbors = get_tree().get_nodes_in_group("units")
	for other in neighbors:
		if other == unit: continue
		var other_pos = other.global_position
		var d = next_pos.distance_to(other_pos)
		if d < 1.0: # Minimum distance between units
			var avoid_dir = (next_pos - other_pos).normalized()
			next_pos += avoid_dir * (1.0 - d) * 0.5
			
	unit.global_position = next_pos
	
	# 6. Face movement direction
	if intended_vel.length() > 0.1:
		var look_target = next_pos + intended_vel
		unit.look_at(Vector3(look_target.x, next_pos.y, look_target.z), Vector3.UP)

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

