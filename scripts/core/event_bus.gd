extends Node

# Event Bus for decoupled system communication

signal unit_selected(unit: Node)
signal unit_deselected(unit: Node)
signal selection_cleared()
signal selection_box_finished(start_screen: Vector2, end_screen: Vector2)

signal command_issued(units: Array[Node], command_type: String, target: Variant)

signal unit_died(unit: Node)
signal resource_collected(resource_type: String, amount: int)
signal combat_started(attacker: Node, target: Node)
signal combat_ended(attacker: Node, target: Node)
signal combat_interrupt_movement(entity_id: int, new_target_position: Vector3)



signal visibility_changed(unit: Node, is_visible: bool)

var _listeners: Dictionary = {}

func _ready() -> void:
	unit_died.connect(_on_unit_died_cleanup)

func _track_event_throughput() -> void:
	var debug_ui = get_tree().root.get_node_or_null("Main/DebugOverlay")
	if debug_ui and debug_ui.has_method("track_event"):
		debug_ui.track_event()

# Wrappers to track throughput automatically
func _emit_unit_selected(unit: Node) -> void:
	_track_event_throughput()
	unit_selected.emit(unit)

func _emit_selection_cleared() -> void:
	_track_event_throughput()
	selection_cleared.emit()

func _emit_unit_died(unit: Node) -> void:
	_track_event_throughput()
	unit_died.emit(unit)

func emit_command(units: Array[Node], command_type: String, target: Variant) -> void:
	_track_event_throughput()
	if units.size() > 0:
		command_issued.emit(units, command_type, target)


# Safe registration wrapper
func safe_connect(sig_name: String, callable: Callable) -> void:
	if not has_user_signal(sig_name) and not has_signal(sig_name):
		push_error("EventBus: Signal " + sig_name + " does not exist.")
		return

	if not is_connected(sig_name, callable):
		connect(sig_name, callable)
		print("EventBus: Registered listener for ", sig_name)

		var obj = callable.get_object()
		if is_instance_valid(obj):
			if not _listeners.has(obj):
				_listeners[obj] = []
			_listeners[obj].append({"signal": sig_name, "callable": callable})
	else:
		push_warning("EventBus: Duplicate registration blocked for " + sig_name)

func _on_unit_died_cleanup(unit: Node) -> void:
	# Orphan cleanup
	if _listeners.has(unit):
		for reg in _listeners[unit]:
			var sig_name = reg["signal"]
			var callable = reg["callable"]
			if (has_user_signal(sig_name) or has_signal(sig_name)) and is_connected(sig_name, callable):
				disconnect(sig_name, callable)
		_listeners.erase(unit)
		print("EventBus: Cleaned up orphaned listeners for destroyed unit.")
