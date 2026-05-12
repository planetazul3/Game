extends Node
class_name VictoryCondition

signal condition_met(faction_id: int, reason: String)

# Evaluate if this win condition is met. Called periodically by SimulationManager
func evaluate() -> void:
	pass
