extends Node3D
## Simple enemy AI controller that makes enemy units patrol and engage player units.
## Attach to a parent node containing enemy unit instances.

@export var patrol_range: float = 8.0
@export var aggro_range: float = 15.0
@export var patrol_interval: float = 4.0

var patrol_timer: float = 0.0
var startup_delay: float = 1.0 # Wait for NavigationServer to sync

func _physics_process(delta: float) -> void:
	# Wait for NavigationServer to complete first map sync
	if startup_delay > 0:
		startup_delay -= delta
		return
	
	patrol_timer -= delta
	
	for child in get_children():
		if not is_instance_valid(child): continue
		if not child.has_method("move_to"): continue
		if child.hp <= 0: continue
		
		# If already attacking, let them fight
		if child.current_state == child.State.ATTACK:
			continue
		
		# Look for nearby player units to attack
		var nearest_enemy = _find_nearest_player_unit(child, aggro_range)
		if nearest_enemy:
			child.attack(nearest_enemy)
			continue
		
		# Patrol randomly when idle
		if child.current_state == child.State.IDLE and patrol_timer <= 0:
			var offset = Vector3(
				randf_range(-patrol_range, patrol_range),
				0,
				randf_range(-patrol_range, patrol_range)
			)
			var patrol_target = child.global_position + offset
			# Clamp to map bounds
			patrol_target.x = clampf(patrol_target.x, -35, 35)
			patrol_target.z = clampf(patrol_target.z, -35, 35)
			child.move_to(patrol_target, true) # Attack-move patrol
	
	if patrol_timer <= 0:
		patrol_timer = patrol_interval + randf_range(-1.0, 1.0)

func _find_nearest_player_unit(from_unit: Node3D, max_dist: float) -> Node3D:
	var nearest = null
	var min_dist = max_dist
	for unit in UnitRegistry.units:
		if not is_instance_valid(unit): continue
		if unit.faction_id != 0: continue # Only target player units
		if unit.hp <= 0: continue
		var d = from_unit.global_position.distance_to(unit.global_position)
		if d < min_dist:
			min_dist = d
			nearest = unit
	return nearest
