extends Node

class_name GameManager

var current_match_time := 0.0
var active_factions := []

func _process(delta: float) -> void:
	current_match_time += delta

func register_faction(faction_name: String) -> void:
	if faction_name not in active_factions:
		active_factions.append(faction_name)

func start_match() -> void:
	print("Starting RTS match...")
