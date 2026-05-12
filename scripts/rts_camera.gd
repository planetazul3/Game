extends Camera3D

@export var move_speed: float = 20.0
@export var zoom_speed: float = 2.0
@export var rotate_speed: float = 1.0

var target_zoom: float = 15.0
var min_zoom: float = 5.0
var max_zoom: float = 40.0

func _process(delta: float) -> void:
	# WASD Movement
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("camera_forward"): input_dir.y -= 1
	if Input.is_action_pressed("camera_backward"): input_dir.y += 1
	if Input.is_action_pressed("camera_left"): input_dir.x -= 1
	if Input.is_action_pressed("camera_right"): input_dir.x += 1
	
	var move_vec = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	move_vec.y = 0 # Keep camera level
	get_parent().global_position += move_vec * move_speed * delta
	
	# Zoom (handled via FOV or height, let's use height)
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
