extends Node3D

var selected_units: Array[Node] = []
var is_dragging: bool = false
var drag_start: Vector2
var drag_end: Vector2

@onready var selection_box: ColorRect = $CanvasLayer/SelectionBox
@onready var camera: Camera3D = $Camera3D

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_start = event.position
				selection_box.visible = true
				selection_box.size = Vector2.ZERO
			else:
				is_dragging = false
				selection_box.visible = false
				_perform_selection()
				
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_issue_move_command()

func _process(_delta: float) -> void:
	if is_dragging:
		drag_end = get_viewport().get_mouse_position()
		selection_box.position = Vector2(min(drag_start.x, drag_end.x), min(drag_start.y, drag_end.y))
		selection_box.size = (drag_start - drag_end).abs()

func _perform_selection() -> void:
	# If drag area is tiny, it's a single click
	var rect = Rect2(selection_box.position, selection_box.size)
	var single_click = rect.size.length() < 5.0
	
	if not Input.is_key_pressed(KEY_SHIFT):
		for unit in selected_units:
			if is_instance_valid(unit):
				unit.selected = false
		selected_units.clear()
	
	if single_click:
		_select_at_position(drag_start)
	else:
		_select_in_rect(rect)

func _select_at_position(screen_pos: Vector2) -> void:
	var from = camera.project_ray_origin(screen_pos)
	var to = from + camera.project_ray_normal(screen_pos) * 1000.0
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result:
		var target = result.collider
		print("Raycast hit: ", target.name, " Class: ", target.get_class())
		if target is CharacterBody3D:
			if target.is_in_group("units") and target.faction_id == 0:
				target.selected = true
				selected_units.append(target)
				print("Selected unit: ", target.name)
			else:
				print("Target is unit but faction mismatch or not in group. Faction: ", target.get("faction_id"))

func _select_in_rect(rect: Rect2) -> void:
	var units = UnitRegistry.units
	for unit in units:
		if is_instance_valid(unit) and unit.faction_id == 0:
			var screen_pos = camera.unproject_position(unit.global_position)
			if rect.has_point(screen_pos):
				unit.selected = true
				if unit not in selected_units:
					selected_units.append(unit)

func _issue_move_command() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000.0
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result:
		var target_obj = result.collider
		
		# Check if we clicked an enemy unit
		if target_obj.is_in_group("units") and target_obj.faction_id != 0:
			_spawn_attack_marker(target_obj.global_position)
			for unit in selected_units:
				if is_instance_valid(unit):
					unit.attack(target_obj)
		else:
			# Just move to position
			var target_pos = result.position
			
			var is_attack_move = Input.is_key_pressed(KEY_A)
			_spawn_move_marker(target_pos if not is_attack_move else target_pos) # Could use different color
			
			print("Issuing move command to ", selected_units.size(), " units to ", target_pos)
			for unit in selected_units:
				if is_instance_valid(unit):
					unit.move_to(target_pos, is_attack_move)

func _spawn_move_marker(pos: Vector3) -> void:
	var marker_scene = load("res://scenes/move_marker.tscn")
	if marker_scene:
		var marker = marker_scene.instantiate()
		get_tree().root.add_child(marker)
		marker.global_position = pos

func _spawn_attack_marker(pos: Vector3) -> void:
	var marker_scene = load("res://scenes/attack_marker.tscn")
	if marker_scene:
		var marker = marker_scene.instantiate()
		get_tree().root.add_child(marker)
		marker.global_position = pos
