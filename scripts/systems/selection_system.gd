extends Node
class_name SelectionSystem

var selected_units: Array[Node] = []

func _ready() -> void:
	if EventBus:
		EventBus.safe_connect("selection_area_defined", _on_selection_area_defined)

func _on_selection_area_defined(start: Vector2, end: Vector2) -> void:
	# Clear previous selection
	for unit in selected_units:
		if is_instance_valid(unit) and unit.has_method("deselect"):
			unit.deselect()
	selected_units.clear()
	EventBus.selection_cleared.emit()

	# Define selection rectangle
	var rect = Rect2(start, end - start).abs()
	
	# If the rectangle is very small, treat it as a single click
	if rect.size.length() < 5.0:
		_handle_single_click(start)
		return

	# Box selection
	var all_units = get_tree().get_nodes_in_group("units")
	var camera = get_viewport().get_camera_3d()
	
	for unit in all_units:
		if not is_instance_valid(unit): continue
		
		# Only select player units
		if unit.get("faction_id") != FactionRegistry.get_player_faction_id():
			continue

		var screen_pos = camera.unproject_position(unit.global_position)
		if rect.has_point(screen_pos):
			_select_unit(unit)

func _handle_single_click(screen_pos: Vector2) -> void:
	var camera = get_viewport().get_camera_3d()
	var from = camera.project_ray_origin(screen_pos)
	var to = from + camera.project_ray_normal(screen_pos) * 1000.0
	
	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true # In case units use Areas
	
	var result = space_state.intersect_ray(query)
	if result.has("collider"):
		var collider = result["collider"]
		# Traverse up to find the Unit node if collider is a child
		var unit = collider
		while unit and not unit is Unit:
			unit = unit.get_parent()
		
		if unit and unit is Unit:
			if unit.faction_id == FactionRegistry.get_player_faction_id():
				_select_unit(unit)

func _select_unit(unit: Node) -> void:
	if unit not in selected_units:
		selected_units.append(unit)
		if unit.has_method("select"):
			unit.select()
		EventBus.unit_selected.emit(unit)

func get_selected_unit_ids() -> Array[int]:
	var ids: Array[int] = []
	for unit in selected_units:
		if is_instance_valid(unit):
			if unit.has_meta("entity_id"):
				ids.append(unit.get_meta("entity_id"))
	return ids
