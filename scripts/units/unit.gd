extends CharacterBody3D
class_name Unit

var health_component: HealthComponent
var visibility_component: VisibilityComponent
var movement_component: MovementComponent
var combat_component: CombatComponent
var gatherer_component: GathererComponent
var ai_component: AIComponent

func _init() -> void:
	health_component = HealthComponent.new()
	visibility_component = VisibilityComponent.new()
	movement_component = MovementComponent.new()
	combat_component = CombatComponent.new()
	gatherer_component = GathererComponent.new()
	ai_component = AIComponent.new()
	
	_setup_fsm()

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
