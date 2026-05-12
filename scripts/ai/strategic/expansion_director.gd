extends RefCounted
class_name ExpansionDirector
# ExpansionDirector: Identifies and plans expansions

var faction_id: int
var known_resource_nodes: Array = []

func update(my_units: Array[Node]) -> void:
	# 1. Scan for resource nodes via SpatialGrid (if nodes are registered)
	# For now, placeholder expansion logic
	pass
