extends Resource
class_name AbilityEffect
# AbilityEffect: Base class for deterministic combat effects

enum EffectType { DAMAGE, HEAL, SHIELD, BUFF, DEBUFF, STATUS, DOT, HOT, CLOAK }

@export var type: EffectType
@export var value: float = 0.0
@export var duration: float = 0.0
@export var radius: float = 0.0 # 0 = single target
