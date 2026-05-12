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

func _simulation_step(delta_fixed: float) -> void:
	current_tick += 1
	
	# Consume commands for this tick
	var tick_commands = command_buffer.consume_tick_commands(current_tick)
	
	# Distribute commands to systems (primarily CommandSystem)
	for system in _ordered_systems:
		if system is CommandSystem:
			system.process_commands(tick_commands)
		
		if system.has_method("tick"):
			system.tick(delta_fixed)
		elif system.has_method("simulation_tick"):
			system.simulation_tick(delta_fixed)

	# Evaluate victory conditions deterministically every second (30 ticks)
	if not _match_ended and current_tick % 30 == 0:
		for vc in _victory_conditions:
			if vc.evaluate(self):
				_on_victory_condition_met(0, "Condition Met")

func seed_simulation(simulation_seed: int) -> void:
	var deterministic_rng = get_node_or_null("/root/DeterministicRandom")
	if deterministic_rng:
		deterministic_rng._rng.seed = simulation_seed
		print("SimulationManager: Seeded simulation with ", simulation_seed)
