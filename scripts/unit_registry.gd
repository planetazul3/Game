extends Node

var units: Array = []

func register(unit: Node3D) -> void:
	if not units.has(unit):
		units.append(unit)
		print("Registered unit: ", unit.name, " (Total: ", units.size(), ")")

func unregister(unit: Node3D) -> void:
	if units.has(unit):
		units.erase(unit)
		print("Unregistered unit: ", unit.name, " (Total: ", units.size(), ")")

func get_units() -> Array:
	return units
