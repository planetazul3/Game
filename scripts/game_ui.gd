extends CanvasLayer

@onready var player_count_label: Label = $HUD/PlayerCount
@onready var enemy_count_label: Label = $HUD/EnemyCount
@onready var win_screen: Control = $WinScreen
@onready var win_label: Label = $WinScreen/Panel/VBoxContainer/WinLabel

func _process(_delta: float) -> void:
	var units = get_tree().get_nodes_in_group("units")
	var p_count = 0
	var e_count = 0
	for u in units:
		if u.faction_id == 0: p_count += 1
		else: e_count += 1
		
	player_count_label.text = "Units: " + str(p_count)
	enemy_count_label.text = "Enemies: " + str(e_count)
	
	if p_count == 0:
		_show_win_screen("DEFEAT")
	elif e_count == 0:
		_show_win_screen("VICTORY")

func _show_win_screen(msg: String) -> void:
	if win_screen.visible: return
	win_label.text = msg
	win_screen.visible = true
	get_tree().paused = true

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
