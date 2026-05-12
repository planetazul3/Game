extends Node
class_name SimulationManager

var current_tick := 0
var simulation_running := true
var active_factions: Array = []

# Systems to be ticked in a deterministic order
var _systems: Array[Node] = []

var _victory_conditions: Array[VictoryCondition] = []
var _match_ended := false

func _ready() -> void:
	for child in get_parent().get_children():
		if child != self and child.has_method("simulation_tick"):
			_systems.append(child)

func register_victory_condition(vc: VictoryCondition) -> void:
	if vc not in _victory_conditions:
		_victory_conditions.append(vc)

func _on_victory_condition_met(faction_id: int, reason: String) -> void:
	if _match_ended: return
	_match_ended = true
	print("Match Ended! Faction ", faction_id, " won via ", reason)

func register_system(system: Node) -> void:
	if system not in _systems and system.has_method("simulation_tick"):
		_systems.append(system)

func _physics_process(delta: float) -> void:
	if not simulation_running:
		return

	current_tick += 1

	for system in _systems:
		system.simulation_tick(delta)

	# Evaluate victory
	if not _match_ended and current_tick % 60 == 0: # Check once a second
		for vc in _victory_conditions:
			if vc.evaluate(self):
				_on_victory_condition_met(0, "Condition Met") # Placeholder for faction/reason
