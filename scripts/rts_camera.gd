extends Camera3D

@export var move_speed: float = 20.0
@export var zoom_speed: float = 2.0
@export var rotate_speed: float = 1.0
@export var edge_scroll_margin: float = 15.0
@export var edge_scroll_speed: float = 15.0

var target_zoom: float = 15.0
var min_zoom: float = 5.0
var max_zoom: float = 35.0

# Map bounds
var map_min := Vector3(-48, 0, -48)
var map_max := Vector3(48, 0, 48)

func _process(delta: float) -> void:
	# WASD Movement
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("camera_forward"): input_dir.y -= 1
	if Input.is_action_pressed("camera_backward"): input_dir.y += 1
	if Input.is_action_pressed("camera_left"): input_dir.x -= 1
	if Input.is_action_pressed("camera_right"): input_dir.x += 1
	
	# Edge scrolling
	var viewport_size = get_viewport().get_visible_rect().size
	var mouse_pos = get_viewport().get_mouse_position()
	
	if mouse_pos.x < edge_scroll_margin:
		input_dir.x -= 1.0
	elif mouse_pos.x > viewport_size.x - edge_scroll_margin:
		input_dir.x += 1.0
	if mouse_pos.y < edge_scroll_margin:
		input_dir.y -= 1.0
	elif mouse_pos.y > viewport_size.y - edge_scroll_margin:
		input_dir.y += 1.0
	
	var move_vec = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	move_vec.y = 0 # Keep camera level
	var actual_speed = move_speed * (target_zoom / 15.0) # Speed scales with zoom
	get_parent().global_position += move_vec * actual_speed * delta
	
	# Clamp position to map bounds
	var pos = get_parent().global_position
	pos.x = clampf(pos.x, map_min.x, map_max.x)
	pos.z = clampf(pos.z, map_min.z, map_max.z)
	get_parent().global_position = pos
	
	# Zoom
	if Input.is_action_just_pressed("camera_zoom_in"):
		target_zoom = clamp(target_zoom - zoom_speed, min_zoom, max_zoom)
	if Input.is_action_just_pressed("camera_zoom_out"):
		target_zoom = clamp(target_zoom + zoom_speed, min_zoom, max_zoom)
		
	# Middle Mouse Rotation
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		var mouse_delta = Input.get_last_mouse_velocity() * delta * 0.1
		get_parent().rotate_y(-deg_to_rad(mouse_delta.x * rotate_speed))
		
	position.y = lerp(position.y, target_zoom, delta * 5.0)
	look_at(get_parent().global_position, Vector3.UP)
