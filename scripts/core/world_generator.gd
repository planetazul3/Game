extends Node

func _ready() -> void:
	var current_seed = DeterministicRandom.get_seed()
	print("WorldGenerator initialized with seed: ", current_seed)
