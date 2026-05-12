extends CharacterBody3D
class_name Unit

var health_component: HealthComponent
var visibility_component: VisibilityComponent
var movement_component: MovementComponent
var combat_component: CombatComponent
var gatherer_component: GathererComponent
var ai_component: AIComponent

@export var definition: UnitDefinition
var faction_id: int = 0

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
	var idle = load("res://scripts/ai/states/idle_state.gd").new(self, fsm)
	var move = load("res://scripts/ai/states/move_state.gd").new(self, fsm)
	var attack = load("res://scripts/ai/states/attack_state.gd").new(self, fsm)
	
	fsm.add_state("idle", idle)
	fsm.add_state("move", move)
	fsm.add_state("attack", attack)
	fsm.add_state("Harvest", HarvestState.new(self, fsm))
	fsm.add_state("Dead", DeadState.new(self, fsm))
	
	fsm.change_state("idle")
	ai_component.state_machine = fsm

func _ready() -> void:
	add_to_group("units")
	if EventBus:
		EventBus.safe_connect("unit_died", _on_unit_died)
	
	# Add placeholder mesh if none exists
	if get_child_count() == 0:
		var mesh_instance = MeshInstance3D.new()
		var capsule = CapsuleMesh.new()
		capsule.radius = 0.5
		capsule.height = 2.0
		mesh_instance.mesh = capsule
		mesh_instance.position.y = 1.0
		add_child(mesh_instance)

func select() -> void:
	var circle = get_node_or_null("SelectionCircle")
	if circle:
		circle.visible = true

func deselect() -> void:
	var circle = get_node_or_null("SelectionCircle")
	if circle:
		circle.visible = false

func _on_unit_died(unit: Node) -> void:
	if unit == self:
		EntityFactory.destroy_entity(self)
