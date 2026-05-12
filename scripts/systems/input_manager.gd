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

	if event is InputEventMouseMotion:
		if _is_selecting:
			_drag_end = event.position
