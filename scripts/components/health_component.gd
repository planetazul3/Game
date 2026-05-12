extends RefCounted
class_name HealthComponent

var max_health: float = 100.0
var current_health: float = 100.0

func is_dead() -> bool:
    return current_health <= 0.0
