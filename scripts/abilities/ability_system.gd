extends Node
class_name AbilitySystem
# AbilitySystem: Manages cooldowns and casting for unit abilities

var AbilityDefinitionClass = load("res://scripts/abilities/ability_definition.gd")
var AbilityEffectClass = load("res://scripts/abilities/ability_effect.gd")

# unit_abilities[entity_id] = { ability_index: current_cooldown }
var _cooldowns: Dictionary = {}

func tick(delta: float) -> void:
	# Update cooldowns
	for id in _cooldowns:
		var ability_map = _cooldowns[id]
		for idx in ability_map:
			if ability_map[idx] > 0:
				ability_map[idx] = max(0, ability_map[idx] - delta)

func can_cast(entity: Node, ability_idx: int, definition) -> bool:
	var id = entity.get_meta("entity_id")
	var ability_map = _cooldowns.get(id, {})
	return ability_map.get(ability_idx, 0.0) <= 0.0

func start_cooldown(entity: Node, ability_idx: int, definition) -> void:
	var id = entity.get_meta("entity_id")
	if not _cooldowns.has(id):
		_cooldowns[id] = {}
	_cooldowns[id][ability_idx] = definition.cooldown

func cast_ability(caster: Node, ability_idx: int, definition, target: Variant) -> void:
	if not can_cast(caster, ability_idx, definition): return
	
	# Consume costs, start cooldown
	start_cooldown(caster, ability_idx, definition)
	
	# Process effects
	for effect in definition.effects:
		EffectProcessor.apply_effect(caster, effect, target)

func save_state() -> Dictionary:
	return { "cooldowns": _cooldowns.duplicate(true) }

func load_state(state: Dictionary) -> void:
	_cooldowns = state.cooldowns.duplicate(true)
