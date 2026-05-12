extends GameContent
class_name AbilityDefinition
# AbilityDefinition: Data-driven template for combat abilities

@export var name: String = "Unnamed Ability"
@export var cooldown: float = 1.0
@export var energy_cost: float = 0.0
@export var range: float = 10.0
@export var cast_time: float = 0.0

# List of effects to apply (AoE, DOT, etc.)
@export var effects: Array[Resource] = []
