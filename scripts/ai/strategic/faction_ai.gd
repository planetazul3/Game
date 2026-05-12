extends Node
class_name FactionAI
# FactionAI: Root strategic layer for a single faction

@export var faction_id: int

var economy_director: EconomyDirector
var combat_director: CombatDirector
var threat_analyzer: ThreatAnalyzer
var expansion_director: ExpansionDirector

var update_tick_interval: int = 30 # Once per second
var last_update_tick: int = 0

func _init() -> void:
	economy_director = EconomyDirector.new()
	combat_director = CombatDirector.new()
	threat_analyzer = ThreatAnalyzer.new()
	expansion_director = ExpansionDirector.new()
	
	economy_director.faction_id = faction_id
	combat_director.faction_id = faction_id
	threat_analyzer.faction_id = faction_id
	expansion_director.faction_id = faction_id

func tick(current_tick: int, delta: float) -> void:
	if current_tick - last_update_tick < update_tick_interval:
		return
	last_update_tick = current_tick
	
	# 1. Update Analysis
	threat_analyzer.update_analysis()
	
	# 2. Gather Data
	var my_units = _get_my_units()
	var resources = _get_resources()
	
	# 3. Direct Layers
	economy_director.update(resources, my_units)
	combat_director.update(threat_analyzer, my_units)
	expansion_director.update(my_units)

func _get_my_units() -> Array[Node]:
	var all_units = EntityManager.get_all_entities()
	var mine = []
	for id in all_units:
		var entity = all_units[id]
		var vis_comp = entity.get("visibility_component")
		if vis_comp and vis_comp.faction_id == faction_id:
			mine.append(entity)
	return mine

func _get_resources() -> Dictionary:
	# Assume ResourceSystem or a global registry has this
	return {"gold": 100} 
