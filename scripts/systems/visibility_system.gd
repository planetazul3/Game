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

var _entities_to_check: Array[Node] = []
var _vision_sources: Array[Node] = []
var _results: Array[bool] = []

func _recalculate_visibility() -> void:
	var all_entities = EntityManager.get_nodes_with_component("VisibilityComponent")
	_entities_to_check.clear()
	_vision_sources.clear()
	
	# 1. Identify all vision sources for the player
	for entity in all_entities:
		var vis_comp = entity.get("visibility_component") as VisibilityComponent
		if not vis_comp: continue
		
		if vis_comp.faction_id == FactionRegistry.get_player_faction_id():
			_vision_sources.append(entity)
		else:
			_entities_to_check.append(entity)

	# 2. Update Fog of War Rendering
	var fow_manager = get_tree().root.get_node_or_null("Main/Systems/FogOfWarManager")
	if fow_manager:
		fow_manager.update_vision(_vision_sources)

	# 3. Parallel Computation
	if _entities_to_check.is_empty(): return
	
	_results.resize(_entities_to_check.size())
	_results.fill(false)
	
	JobSystem.run_job_group(_entities_to_check.size(), _visibility_job)
	JobSystem.wait_for_all()
	
	# 4. Deterministic Reduction (Apply results in stable order)
	var merge_start = Time.get_ticks_usec()
	for i in range(_entities_to_check.size()):
		var entity = _entities_to_check[i]
		var vis_comp = entity.get("visibility_component") as VisibilityComponent
		_apply_visibility_state(entity, vis_comp, _results[i])
	JobSystem.last_merge_ms = (Time.get_ticks_usec() - merge_start) / 1000.0

func _visibility_job(index: int) -> void:
	var entity = _entities_to_check[index]
	var entity_pos = entity.global_position
	if "movement_component" in entity: entity_pos = entity.movement_component.simulation_position
	
	for source in _vision_sources:
		var s_vis = source.get("visibility_component") as VisibilityComponent
		var source_pos = source.global_position
		if "movement_component" in source: source_pos = source.movement_component.simulation_position
		
		var dist_sq = source_pos.distance_squared_to(entity_pos)
		if dist_sq <= s_vis.vision_range * s_vis.vision_range:
			_results[index] = true
			break

func _apply_visibility_state(entity: Node, vis_comp: VisibilityComponent, is_visible: bool) -> void:
	if is_visible:
		if vis_comp.current_state != VisibilityComponent.VisibilityState.VISIBLE:
			vis_comp.current_state = VisibilityComponent.VisibilityState.VISIBLE
			EventBus.visibility_changed.emit(entity, true)
	else:
		if vis_comp.current_state == VisibilityComponent.VisibilityState.VISIBLE:
			vis_comp.current_state = VisibilityComponent.VisibilityState.EXPLORED
			EventBus.visibility_changed.emit(entity, false)
