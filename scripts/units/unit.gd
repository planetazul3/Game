extends CharacterBody3D
class_name Unit

var health_component: HealthComponent
var visibility_component: VisibilityComponent
var movement_component: MovementComponent
var combat_component: CombatComponent

func _init() -> void:
	health_component = HealthComponent.new()
	visibility_component = VisibilityComponent.new()
	movement_component = MovementComponent.new()
	combat_component = CombatComponent.new()

func _ready() -> void:
	if EventBus:
		EventBus.safe_connect("unit_died", _on_unit_died)

func _on_unit_died(unit: Node) -> void:
	if unit == self:
		EntityManager.destroy_entity(self)
