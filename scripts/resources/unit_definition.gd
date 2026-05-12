extends Resource
class_name UnitDefinition

@export var unit_name: String = "Soldier"
@export var max_health: float = 100.0
@export var movement_speed: float = 5.0
@export var attack_damage: float = 10.0
@export var attack_range: float = 2.0
@export var attack_cooldown: float = 1.0
@export var sight_range: float = 15.0
@export var faction: String = "Neutral"
@export var prefab_scene: PackedScene
@export var weapon_definition: WeaponDefinition
