extends Node
class_name InputManager

var _is_selecting: bool = false
var _drag_start: Vector2 = Vector2.ZERO
var _drag_end: Vector2 = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Iniciar selección
				_is_selecting = true
				_drag_start = event.position
				_drag_end = event.position
			else:
				# Finalizar selección
				if _is_selecting:
					_is_selecting = false
					_drag_end = event.position
					# Emitir la señal de área definida
					EventBus.selection_area_defined.emit(_drag_start, _drag_end)

		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			# El jugador ha hecho clic derecho
			var camera: Camera3D = get_viewport().get_camera_3d()
			if camera == null:
				return
			
			var from: Vector3 = camera.project_ray_origin(event.position)
			var dir: Vector3 = camera.project_ray_normal(event.position)
			var to: Vector3 = from + dir * 1000.0
			var space_state: PhysicsDirectSpaceState3D = camera.get_world_3d().direct_space_state
			var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
			var result: Dictionary = space_state.intersect_ray(query)

			var world_position: Vector3 = Vector3.ZERO
			if result.has("position"):
				world_position = result["position"]
			else:
				# Si no choca con nada, calcular la intersección con el plano y=0
				var plane: Plane = Plane(Vector3.UP, 0.0)
				var intersection = plane.intersects_ray(from, dir)
				if intersection != null:
					world_position = intersection

			# Enqueue command into SimulationManager's buffer
			var sim_manager = get_tree().root.find_child("SimulationManager", true, false)
			if sim_manager and sim_manager is SimulationManager:
				# We issue the command for the NEXT tick to ensure it's processed after the current one
				var target_tick = sim_manager.current_tick + 1
				var issuer_id = 0 # Default player ID
				var cmd = CommandBuffer.Command.new(target_tick, issuer_id, 0, "move", world_position)
				sim_manager.command_buffer.enqueue_command(cmd)


	if event is InputEventMouseMotion:
		if _is_selecting:
			_drag_end = event.position
