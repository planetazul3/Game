extends Node
# TacticalInfluenceSystem: Manages strategic maps for AI reasoning

@export var map_width: int = 100
@export var map_height: int = 100
@export var cell_size: float = 2.0

var InfluenceMapClass = load("res://scripts/ai/influence/influence_map.gd")

var threat_map
var control_map
var resource_map

var update_interval: float = 1.0 # 1Hz is enough for strategic maps
var update_timer: float = 0.0

func _ready() -> void:
	threat_map = InfluenceMapClass.new(map_width, map_height, cell_size)
	control_map = InfluenceMapClass.new(map_width, map_height, cell_size)
	resource_map = InfluenceMapClass.new(map_width, map_height, cell_size)

func tick(delta: float) -> void:
	update_timer -= delta
	if update_timer <= 0:
		update_timer = update_interval
		_update_maps()

func _update_maps() -> void:
	threat_map.clear()
	control_map.clear()
	resource_map.clear()
	
	var entities = EntityManager.get_all_entities()
	var player_faction = FactionRegistry.get_player_faction_id()
	
	for entity in entities:
		if not is_instance_valid(entity): continue
		
		# 1. Combat Influence
		var combat_comp = entity.get("combat_component")
		var vis_comp = entity.get("visibility_component")
		var move_comp = entity.get("movement_component")
		
		if combat_comp and vis_comp:
			var pos = entity.global_position
			if move_comp: pos = move_comp.simulation_position
			
			var power = combat_comp.attack_damage * combat_comp.attack_speed
			var radius = 10.0 # Influence radius
			
			if vis_comp.faction_id == player_faction:
				control_map.add_influence(pos, power, radius)
			else:
				threat_map.add_influence(pos, power, radius)
				control_map.add_influence(pos, -power, radius) # Enemy reduces control
				
		# 2. Resource Influence
		var res_comp = entity.get("resource_component")
		if res_comp:
			resource_map.add_influence(entity.global_position, 1.0, 15.0)

func get_threat_at(pos: Vector3) -> float:
	return threat_map.get_influence(pos)

func get_control_at(pos: Vector3) -> float:
	return control_map.get_influence(pos)

func get_resource_density_at(pos: Vector3) -> float:
	return resource_map.get_influence(pos)

func get_best_expansion_point(search_radius: float) -> Vector3:
	# Simplified: find high resource, low threat, low control
	# In a real game, we'd sample a grid or use pre-calculated scores
	return Vector3.ZERO # Stub
