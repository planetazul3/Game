extends CanvasLayer

@onready var fps_label: Label = $MarginContainer/VBoxContainer/FPSLabel
@onready var tick_label: Label = $MarginContainer/VBoxContainer/TickLabel
@onready var unit_label: Label = $MarginContainer/VBoxContainer/UnitLabel
@onready var selected_label: Label = $MarginContainer/VBoxContainer/SelectedLabel
@onready var ai_label: Label = $MarginContainer/VBoxContainer/AILabel
@onready var path_req_label: Label = $MarginContainer/VBoxContainer/PathReqLabel
@onready var combat_label: Label = $MarginContainer/VBoxContainer/CombatLabel
@onready var vis_cells_label: Label = $MarginContainer/VBoxContainer/VisibleCellsLabel
@onready var event_bus_label: Label = $MarginContainer/VBoxContainer/EventBusLabel
@onready var memory_label: Label = $MarginContainer/VBoxContainer/MemoryLabel

var _event_count := 0
var _event_timer := 0.0
var _last_events_per_sec := 0

func _ready() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F3 or event.keycode == KEY_QUOTELEFT:
			visible = not visible

func track_event() -> void:
	_event_count += 1

func _process(delta: float) -> void:
	_event_timer += delta
	if _event_timer >= 1.0:
		_last_events_per_sec = _event_count
		_event_count = 0
		_event_timer = 0.0

	if not visible: return

	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	event_bus_label.text = "Events/s: " + str(_last_events_per_sec)

	var sim_sys = get_tree().current_scene.get_node_or_null("Systems/SimulationManager")
	if sim_sys:
		tick_label.text = "Tick: " + str(sim_sys.current_tick)

	unit_label.text = "Units: " + str(get_tree().get_nodes_in_group("selectable").size())

	var sel_sys = get_tree().current_scene.get_node_or_null("Systems/SelectionSystem")
	if sel_sys:
		selected_label.text = "Selected: " + str(sel_sys.selected_units.size())

	var ai_sys = get_tree().current_scene.get_node_or_null("Systems/AISystem")
	if ai_sys:
		ai_label.text = "AI Agents: " + str(ai_sys.ai_units.size())

	var mov_sys = get_tree().current_scene.get_node_or_null("Systems/MovementSystem")
	if mov_sys:
		path_req_label.text = "Path Reqs: " + str(mov_sys.entities_to_move.size())

	var com_sys = get_tree().current_scene.get_node_or_null("Systems/CombatSystem")
	if com_sys:
		# Very naive engagement proxy for UI
		var engagements = 0
		for u in get_tree().get_nodes_in_group("selectable"):
			var p = u.get_parent()
			if is_instance_valid(p) and p.has_node("CombatComponent") and p.get_node("CombatComponent").target != null:
				engagements += 1
		combat_label.text = "Engagements: " + str(engagements)

	var vis_sys = get_tree().current_scene.get_node_or_null("Systems/VisibilitySystem")
	if vis_sys:
		vis_cells_label.text = "Vis Cells: " + str(vis_sys._spatial_grid.size())

	var mem = OS.get_static_memory_usage() / 1024.0 / 1024.0
	memory_label.text = "Mem: %.2f MB" % mem
