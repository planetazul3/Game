extends Node3D
class_name RTSCamera

@export_category("Movement")
@export var pan_speed := 20.0
@export var edge_pan_margin := 20
@export var edge_pan_speed := 20.0
@export var use_edge_pan := true

@export_category("Zoom")
@export var zoom_speed := 2.0
@export var min_zoom := 5.0
@export var max_zoom := 40.0
@export var zoom_smoothness := 10.0

@onready var elevation_node: Node3D = $Elevation
@onready var camera: Camera3D = $Elevation/Camera3D

var target_zoom := 20.0

func _ready() -> void:
	target_zoom = camera.position.z

func _process(delta: float) -> void:
	_handle_panning(delta)
	_handle_zoom(delta)
	# TODO: Implement terrain adaptation so camera follows ground height
	# TODO: Implement follow target logic

func _handle_panning(delta: float) -> void:
	var direction := Vector3.ZERO

	# Keyboard input
	if Input.is_action_pressed("camera_forward"):
		direction.z -= 1
	if Input.is_action_pressed("camera_backward"):
		direction.z += 1
	if Input.is_action_pressed("camera_left"):
		direction.x -= 1
	if Input.is_action_pressed("camera_right"):
		direction.x += 1

	# Edge panning
	if use_edge_pan:
		var mouse_pos = get_viewport().get_mouse_position()
		var viewport_size = get_viewport().get_visible_rect().size

		if mouse_pos.x < edge_pan_margin:
			direction.x -= 1
		elif mouse_pos.x > viewport_size.x - edge_pan_margin:
			direction.x += 1

		if mouse_pos.y < edge_pan_margin:
			direction.z -= 1
		elif mouse_pos.y > viewport_size.y - edge_pan_margin:
			direction.z += 1

	direction = direction.normalized()
	position += direction * pan_speed * delta

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_zoom_in"):
		target_zoom -= zoom_speed
	elif event.is_action_pressed("camera_zoom_out"):
		target_zoom += zoom_speed

	target_zoom = clamp(target_zoom, min_zoom, max_zoom)

func _handle_zoom(delta: float) -> void:
	camera.position.z = lerp(camera.position.z, target_zoom, zoom_smoothness * delta)
