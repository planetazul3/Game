extends CharacterBody3D
class_name Unit

var health_component: HealthComponent
var visibility_component: VisibilityComponent
var movement_component: MovementComponent
var gatherer_component: GathererComponent
var ai_component: AIComponent

@export var definition: UnitDefinition

func _init(p_definition: UnitDefinition = null) -> void:
	if p_definition:
		definition = p_definition
	
	health_component = HealthComponent.new()
	visibility_component = VisibilityComponent.new()
	movement_component = MovementComponent.new()
	combat_component = CombatComponent.new()
	gatherer_component = GathererComponent.new()
	ai_component = AIComponent.new()
	
	if definition:
		_apply_definition()
	
	_setup_fsm()

func _apply_definition() -> void:
	health_component.max_health = definition.max_health
	health_component.current_health = definition.max_health
	
	movement_component.speed = definition.movement_speed
	
	combat_component.attack_damage = definition.attack_damage
	combat_component.attack_range = definition.attack_range
	combat_component.attack_speed = 1.0 / definition.attack_cooldown
	
	visibility_component.sight_range = definition.sight_range

func _setup_fsm() -> void:
	var fsm = AIStateMachine.new(self)
	fsm.add_state("Idle", IdleState.new(self, fsm))
	fsm.add_state("Move", MoveState.new(self, fsm))
	fsm.add_state("Attack", AttackState.new(self, fsm))
	fsm.add_state("Harvest", HarvestState.new(self, fsm))
	fsm.add_state("Dead", DeadState.new(self, fsm))
	
	fsm.change_state("Idle")
	ai_component.state_machine = fsm

func _ready() -> void:
	if EventBus:
		EventBus.safe_connect("unit_died", _on_unit_died)

func _on_unit_died(unit: Node) -> void:
	if unit == self:
		EntityManager.destroy_entity(self)
