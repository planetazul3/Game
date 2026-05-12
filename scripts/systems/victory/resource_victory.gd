extends VictoryCondition
class_name ResourceVictory

@export var required_energy: int = 5000

func evaluate() -> void:
	var res_sys = get_tree().current_scene.get_node_or_null("Systems/ResourceSystem")
	if not res_sys: return

	if res_sys.resources.get("energy", 0) >= required_energy:
		# Assuming faction 0 is player for vertical slice demo
		condition_met.emit(0, "Economic Dominance")
