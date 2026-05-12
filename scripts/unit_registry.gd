class_name UnitRegistry

static var units: Array = []

static func register(unit: Node3D) -> void:
	if not units.has(unit):
		units.append(unit)

static func unregister(unit: Node3D) -> void:
	units.erase(unit)

static func get_units() -> Array:
	return units
