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
@onready var step_time_label: Label = $MarginContainer/VBoxContainer/StepTimeLabel
@onready var spatial_metrics_label: Label = $MarginContainer/VBoxContainer/SpatialMetricsLabel
@onready var system_timings_label: Label = $MarginContainer/VBoxContainer/SystemTimingsLabel

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
		step_time_label.text = "Step: %.2fms" % sim_sys.last_step_ms
		
		var sys_text = "Systems:\n"
		for sys_name in sim_sys.system_timings:
			sys_text += "  %s: %.2fms\n" % [sys_name, sim_sys.system_timings[sys_name]]
		system_timings_label.text = sys_text

	unit_label.text = "Units: " + str(EntityManager._entities.size())
	spatial_metrics_label.text = "Spatial Q/U: %d / %d" % [SpatialGrid.query_count, SpatialGrid.update_count]

	var sel_sys = get_tree().current_scene.get_node_or_null("Systems/SelectionSystem")
	if sel_sys:
		selected_label.text = "Selected: " + str(sel_sys.selected_units.size())

	ai_label.text = "AI Agents: " + str(ComponentRegistry.get_components_by_type("AIComponent").size())

	var mov_sys = get_tree().current_scene.get_node_or_null("Systems/MovementSystem")
	if mov_sys:
		path_req_label.text = "Path Reqs: " + str(mov_sys.entities_to_move.size())

	var combat_components = ComponentRegistry.get_components_by_type("CombatComponent")
	var engagements = 0
	for comp in combat_components:
		if comp.target != null:
			engagements += 1
	combat_label.text = "Engagements: " + str(engagements)

	var vis_sys = get_tree().current_scene.get_node_or_null("Systems/VisibilitySystem")
	if vis_sys:
		vis_cells_label.text = "Vis Cells: " + str(vis_sys._spatial_grid.size())

	var mem = OS.get_static_memory_usage() / 1024.0 / 1024.0
	memory_label.text = "Mem: %.2f MB" % mem
