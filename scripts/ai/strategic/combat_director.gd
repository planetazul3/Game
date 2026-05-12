extends RefCounted
class_name CombatDirector
# CombatDirector: Manages army and offensive/defensive operations

var faction_id: int
var army_units: Array[Node] = []
var attack_threshold: int = 5

func update(threat_map: ThreatAnalyzer, my_units: Array[Node]) -> void:
	army_units.clear()
	for unit in my_units:
		if unit.get("combat_component"):
			army_units.append(unit)
			
	if army_units.size() >= attack_threshold:
		_launch_attack(threat_map)

func _launch_attack(threat_map: ThreatAnalyzer) -> void:
	# Find a target
	# For now, just pick a threat location or a default enemy base position
	pass
