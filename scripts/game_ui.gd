extends CanvasLayer

@onready var player_count_label: Label = $HUD/PlayerCount
@onready var enemy_count_label: Label = $HUD/EnemyCount
@onready var win_screen: Control = $WinScreen
@onready var win_label: Label = $WinScreen/Panel/VBoxContainer/WinLabel
@onready var objective_label: Label = $HUD/ObjectiveLabel

var game_started: bool = false
var start_delay: float = 0.5

func _ready() -> void:
	win_screen.visible = false
	if objective_label:
		objective_label.text = "OBJECTIVE: Destroy all enemy units"

func _process(delta: float) -> void:
	# Small delay before checking win/lose to let units register
	start_delay -= delta
	if start_delay > 0:
		return
	game_started = true
	
	var units = UnitRegistry.units
	var p_count = 0
	var e_count = 0
	for u in units:
		if is_instance_valid(u) and u.hp > 0:
			if u.faction_id == 0: p_count += 1
			else: e_count += 1
		
	player_count_label.text = "⚔ Units: " + str(p_count)
	enemy_count_label.text = "☠ Enemies: " + str(e_count)
	
	if p_count == 0 and game_started:
		_show_win_screen("DEFEAT", Color(0.8, 0.15, 0.15))
	elif e_count == 0 and game_started:
		_show_win_screen("VICTORY", Color(0.15, 0.8, 0.3))

func _show_win_screen(msg: String, color: Color = Color.WHITE) -> void:
	if win_screen.visible: return
	win_label.text = msg
	win_label.add_theme_color_override("font_color", color)
	win_screen.visible = true
	get_tree().paused = true

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
