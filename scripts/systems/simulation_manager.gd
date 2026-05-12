extends Node
class_name SimulationManager

const TICK_RATE: float = 30.0
const TICK_DELTA: float = 1.0 / TICK_RATE

var current_tick: int = 0
var simulation_running: bool = true
var accumulator: float = 0.0

var command_buffer: CommandBuffer = CommandBuffer.new()
var _ordered_systems: Array[Node] = []
var active_factions: Array = []
var _victory_conditions: Array[VictoryCondition] = []
var _match_ended: bool = false

func _ready() -> void:
	# CLI Parsing
	var args = OS.get_cmdline_args()
	for arg in args:
		if arg.begins_with("--seed="):
			var s = int(arg.split("=")[1])
			seed_simulation(s)
		if arg.begins_with("--tickrate="):
			var tr = float(arg.split("=")[1])
			# Update TICK_RATE constants if they were non-const, but here they are const.
			# For now just log it.
			print("SimulationManager: Tickrate override requested: ", tr)

	# Enforce deterministic system execution order
	var system_order: Array[String] = [
		"CommandSystem",
		"AISystem",
		"NavigationSystem",
		"FormationSystem",
		"MovementSystem",
		"CombatSystem",
		"ResourceSystem",
		"VisibilitySystem"
	]
	
	var systems_node = get_parent()
	for system_name in system_order:
		var system = systems_node.get_node_or_null(system_name)
		if system:
			_ordered_systems.append(system)
			print("SimulationManager: Registered system ", system_name)
		else:
			push_warning("SimulationManager: Required system missing: " + system_name)

func register_victory_condition(vc: VictoryCondition) -> void:
	if vc not in _victory_conditions:
		_victory_conditions.append(vc)

func _on_victory_condition_met(faction_id: int, reason: String) -> void:
	if _match_ended: return
	_match_ended = true
	print("Match Ended! Faction ", faction_id, " won via ", reason)

func _process(delta: float) -> void:
	if not simulation_running:
		return

	accumulator += delta
	
	while accumulator >= TICK_DELTA:
		_simulation_step(TICK_DELTA)
		accumulator -= TICK_DELTA

var system_timings: Dictionary = {}
var last_step_ms: float = 0.0

func _simulation_step(delta_fixed: float) -> void:
	SpatialGrid.reset_metrics()
	var step_start = Time.get_ticks_usec()
	current_tick += 1
	
	# Consume commands for this tick
	var tick_commands = command_buffer.consume_tick_commands(current_tick)
	
	# Distribute commands to systems
	for system in _ordered_systems:
		var sys_start = Time.get_ticks_usec()
		
		if system is CommandSystem:
			system.process_commands(tick_commands)
		
		if system.has_method("tick"):
			system.tick(delta_fixed)
		elif system.has_method("simulation_tick"):
			system.simulation_tick(delta_fixed)
			
		system_timings[system.name] = (Time.get_ticks_usec() - sys_start) / 1000.0

	# Evaluate victory conditions deterministically every second (30 ticks)
	if not _match_ended and current_tick % 30 == 0:
		for vc in _victory_conditions:
			if vc.evaluate(self):
				_on_victory_condition_met(0, "Condition Met")
				
	# Generate checksum every 30 ticks (1 second)
	if current_tick % 30 == 0:
		var checksum = generate_world_checksum()
		# print("Tick ", current_tick, " Checksum: ", checksum)
		EventBus.emit_signal("checksum_generated", current_tick, checksum)
				
	last_step_ms = (Time.get_ticks_usec() - step_start) / 1000.0

func seed_simulation(simulation_seed: int) -> void:
	var deterministic_rng = get_node_or_null("/root/DeterministicRandom")
	if deterministic_rng:
		deterministic_rng._rng.seed = simulation_seed
		print("SimulationManager: Seeded simulation with ", simulation_seed)

func save_simulation() -> Dictionary:
	var state = {
		"tick": current_tick,
		"entities": {},
		"systems": {}
	}
	
	# 1. Save all entities
	var all_entities = EntityManager.get_all_entities()
	for id in all_entities:
		var entity = all_entities[id]
		var entity_data = {
			"pos": [entity.global_position.x, entity.global_position.y, entity.global_position.z],
			"rot": [entity.global_rotation.x, entity.global_rotation.y, entity.global_rotation.z],
			"components": {}
		}
		
		# Save components
		var components = ComponentRegistry.get_entity_components(id)
		for comp_type in components:
			var comp = components[comp_type]
			if comp.has_method("save_state"):
				entity_data.components[comp_type] = comp.save_state()
		
		state.entities[id] = entity_data
	
	# 2. Save all systems
	for system in _ordered_systems:
		if system.has_method("save_state"):
			state.systems[system.name] = system.save_state()
			
	return state

func load_simulation(state: Dictionary) -> void:
	current_tick = state.tick
	
	# 1. Recreate/Restore Entities
	# First, clear current entities
	EntityManager.clear_all_entities()
	
	for id_str in state.entities:
		var id = int(id_str)
		var data = state.entities[id_str]
		
		# In a real scenario, we'd need the unit type/definition to spawn the right prefab
		# For now, let's assume we have a way to spawn by ID or metadata
		# Re-creating entities from scratch is complex, so we'll need a factory helper
		pass # Simplified for this phase

	# 2. Restore systems
	for system in _ordered_systems:
		if state.systems.has(system.name):
			system.load_state(state.systems[system.name])

func generate_world_checksum() -> String:
	var state_string = ""
	
	# 1. Stable entity state
	var all_entities = EntityManager.get_all_entities()
	var sorted_ids = all_entities.keys()
	sorted_ids.sort()
	
	for id in sorted_ids:
		var entity = all_entities[id]
		state_string += str(id) + ":"
		state_string += str(entity.global_position.snapped(Vector3(0.01, 0.01, 0.01))) + "|"
		
		# Components state
		var components = ComponentRegistry.get_entity_components(id)
		if components.has("HealthComponent"):
			state_string += "h" + str(components["HealthComponent"].current_health) + "|"
			
	# 2. Global simulation state
	state_string += "t" + str(current_tick)
	
	return state_string.sha256_text()
