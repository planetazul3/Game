extends Node
class_name VisibilitySystem

var update_timer: float = 0.0
var update_interval: float = 0.5 # Throttle recalculations

func _ready() -> void:
	pass

func tick(delta: float) -> void:
	update_timer -= delta
	if update_timer > 0:
		return

	update_timer = update_interval
	_recalculate_visibility()

func _recalculate_visibility() -> void:
	var entities = EntityManager.get_nodes_with_component("VisibilityComponent")
	var player_vision_sources: Array[Node] = []

	# 1. Identify all vision sources for the player
	for entity in entities:
		var vis_comp = entity.get("visibility_component") as VisibilityComponent
		if not vis_comp: continue
		
		if vis_comp.faction_id == FactionRegistry.get_player_faction_id():
			player_vision_sources.append(entity)

	# 2. Update Fog of War Rendering
	var fow_manager = get_tree().root.get_node_or_null("Main/Systems/FogOfWarManager")
	if fow_manager:
		fow_manager.update_vision(player_vision_sources)

	# 3. Update visibility for all units
	for entity in entities:
		var vis_comp = entity.get("visibility_component") as VisibilityComponent
		if not vis_comp or vis_comp.faction_id == FactionRegistry.get_player_faction_id(): continue
		
		var currently_visible = false
		
		# Optimization: Only check entities that are within range of ANY player vision source
		# In a large map, we'd query the grid for cells near the entity.
		for source in player_vision_sources:
			var s_vis = source.get("visibility_component") as VisibilityComponent
			if not s_vis: continue
			
			var dist_sq = source.global_position.distance_squared_to(entity.global_position)
			if dist_sq <= s_vis.vision_range * s_vis.vision_range:
				currently_visible = true
				break
		
		_apply_visibility_state(entity, vis_comp, currently_visible)

func _apply_visibility_state(entity: Node, vis_comp: VisibilityComponent, is_visible: bool) -> void:
	if is_visible:
		if vis_comp.current_state != VisibilityComponent.VisibilityState.VISIBLE:
			vis_comp.current_state = VisibilityComponent.VisibilityState.VISIBLE
			EventBus.visibility_changed.emit(entity, true)
	else:
		if vis_comp.current_state == VisibilityComponent.VisibilityState.VISIBLE:
			vis_comp.current_state = VisibilityComponent.VisibilityState.EXPLORED
			EventBus.visibility_changed.emit(entity, false)
