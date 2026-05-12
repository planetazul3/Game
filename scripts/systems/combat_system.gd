extends Node
class_name CombatSystem

var combatants: Array[Node] = []

func _ready() -> void:
	pass

func simulation_tick(delta: float) -> void:
	var scene_units = get_tree().get_nodes_in_group("selectable")
	for sel in scene_units:
		var entity = sel.get_parent()
		if not is_instance_valid(entity): continue

		var combat_comp = entity.get("combat_component") as CombatComponent
		if not combat_comp: continue

		if combat_comp.attack_cooldown > 0:
			combat_comp.attack_cooldown -= delta

		var target = combat_comp.target
		if is_instance_valid(target) and "health_component" in target:
			var distance = entity.global_position.distance_to(target.global_position)
			if distance <= combat_comp.attack_range:
				if combat_comp.attack_cooldown <= 0:
					_process_damage(entity, target, combat_comp.attack_damage)
					combat_comp.attack_cooldown = 1.0 / combat_comp.attack_speed
			else:
				var move_comp = entity.get("movement_component") as MovementComponent
				if move_comp:
					move_comp.target_position = target.global_position
					move_comp.has_target = true

					EventBus.combat_interrupt_movement.emit(entity.get_instance_id(), target.global_position)

		else:
			combat_comp.target = null

func _process_damage(attacker: Node, target: Node, amount: float) -> void:
	var health = target.get("health_component") as HealthComponent
	if not health: return

	health.current_health = max(health.current_health - amount, 0.0)

	EventBus._track_event_throughput()
	EventBus.combat_started.emit(attacker, target)

	if health.current_health <= 0:
		EventBus._emit_unit_died(target)
