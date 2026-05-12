extends CharacterBody3D
class_name Unit

func _ready() -> void:
	if EventBus:
		EventBus.safe_connect("unit_died", _on_unit_died)

func _on_unit_died(unit: Node) -> void:
	if unit == self:
		EntityManager.destroy_entity(self)
