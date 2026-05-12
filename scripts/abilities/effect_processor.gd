extends Node
# EffectProcessor: Executes deterministic logic for ability effects

func apply_effect(caster: Node, effect, target: Variant) -> void:
	if effect.radius > 0:
		_apply_aoe(caster, effect, target)
	else:
		_apply_single_target(caster, effect, target)

func _apply_single_target(caster: Node, effect, target: Node) -> void:
	if not is_instance_valid(target): return
	
	match int(effect.type):
		0: # DAMAGE
			_apply_damage(target, effect.value)
		1: # HEAL
			_apply_heal(target, effect.value)

func _apply_aoe(caster: Node, effect, target_pos: Vector3) -> void:
	# Use SpatialGrid for deterministic neighbor lookup
	var targets = SpatialGrid.query_radius(target_pos, effect.radius)
	
	# Sort targets by entity_id for stable resolution
	targets.sort_custom(func(a, b): return a.get_meta("entity_id") < b.get_meta("entity_id"))
	
	for target in targets:
		match int(effect.type):
			0: # DAMAGE
				_apply_damage(target, effect.value)
			1: # HEAL
				_apply_heal(target, effect.value)

static func _apply_damage(target: Node, amount: float) -> void:
	var health = target.get("health_component")
	if health:
		health.current_health = max(0, health.current_health - amount)
		if health.current_health <= 0:
			EventBus._emit_unit_died(target)

static func _apply_heal(target: Node, amount: float) -> void:
	var health = target.get("health_component")
	if health:
		health.current_health = min(health.max_health, health.current_health + amount)
