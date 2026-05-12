extends Node

var _rng: RandomNumberGenerator

func _ready() -> void:
	_rng = RandomNumberGenerator.new()
	_rng.seed = 1337 # Hardcoded seed for development determinism

func randf() -> float:
	return _rng.randf()

func randf_range(from: float, to: float) -> float:
	return _rng.randf_range(from, to)

func randi() -> int:
	return _rng.randi()

func randi_range(from: int, to: int) -> int:
	return _rng.randi_range(from, to)
