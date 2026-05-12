extends Node
class_name VisibilitySystem

# A spatial grid for simple partitioning
const GRID_CELL_SIZE := 20.0

# Dictionary mapping grid cells (Vector2i) to an array of entities inside them
var _spatial_grid: Dictionary = {}

var player_faction_id: int = 0
var update_timer: float = 0.0
var update_interval: float = 0.5 # Throttle recalculations

func _ready() -> void:
	pass

func simulation_tick(delta: float) -> void:
	update_timer -= delta
	if update_timer > 0:
		return

	update_timer = update_interval
	_recalculate_visibility()

func _recalculate_visibility() -> void:
	var scene_units = get_tree().get_nodes_in_group("selectable")

	# 1. Update Spatial Grid
	_spatial_grid.clear()
	var player_vision_sources: Array[Node] = []

	for sel in scene_units:
		var entity = sel.get_parent()
		if not is_instance_valid(entity): continue

		var vis_comp = entity.get("visibility_component") as VisibilityComponent
		if not vis_comp: continue

		var cell = Vector2i(
			int(floor(entity.global_position.x / GRID_CELL_SIZE)),
			int(floor(entity.global_position.z / GRID_CELL_SIZE))
		)
		vis_comp.grid_cell = cell

		if not _spatial_grid.has(cell):
			_spatial_grid[cell] = []
		_spatial_grid[cell].append(entity)

		if vis_comp.faction_id == player_faction_id:
			player_vision_sources.append(entity)

	# 2. Re-evaluate all non-player entities for visibility without toggling
	for sel in scene_units:
		var entity = sel.get_parent()
		if not is_instance_valid(entity): continue

		var vis_comp = entity.get("visibility_component") as VisibilityComponent
		if not vis_comp or vis_comp.faction_id == player_faction_id: continue

		var currently_visible = false

		# Check against all player sources in range using grid
		var target_cell = vis_comp.grid_cell
		for source in player_vision_sources:
			var s_vis = source.get("visibility_component") as VisibilityComponent
			var cell_radius = int(ceil(s_vis.vision_range / GRID_CELL_SIZE))

			if abs(target_cell.x - s_vis.grid_cell.x) <= cell_radius and abs(target_cell.y - s_vis.grid_cell.y) <= cell_radius:
				var range_sq = s_vis.vision_range * s_vis.vision_range
				if source.global_position.distance_squared_to(entity.global_position) <= range_sq:
					currently_visible = true
					break

		# Evaluate state transitions deterministically
		if currently_visible:
			if vis_comp.current_state != VisibilityComponent.VisibilityState.VISIBLE:
				vis_comp.current_state = VisibilityComponent.VisibilityState.VISIBLE
				EventBus.visibility_changed.emit(entity, true)
		else:
			# Not currently visible
			if vis_comp.current_state == VisibilityComponent.VisibilityState.VISIBLE:
				# Drop down to explored
				vis_comp.current_state = VisibilityComponent.VisibilityState.EXPLORED
				EventBus.visibility_changed.emit(entity, false)
			# If already UNEXPLORED or EXPLORED, it stays that way.
