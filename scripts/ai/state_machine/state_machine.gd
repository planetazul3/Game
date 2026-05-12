extends RefCounted
class_name AIStateMachine

var current_state: AIState
var states: Dictionary = {}
var unit: Node

func _init(p_unit: Node) -> void:
	unit = p_unit

func add_state(state_name: String, state: AIState) -> void:
	states[state_name] = state

func change_state(state_name: String, msg: Dictionary = {}) -> void:
	if not states.has(state_name):
		push_error("AIStateMachine: State " + state_name + " not found for unit " + unit.name)
		return
	
	if current_state:
		current_state.exit()
	
	current_state = states[state_name]
	current_state.enter(msg)
	
	# Update component metadata if available
	var ai_comp = unit.get("ai_component")
	if ai_comp:
		ai_comp.current_state_name = state_name

func tick(delta: float) -> void:
	if current_state:
		current_state.tick(delta)

func handle_command(type: String, target: Variant) -> void:
	if current_state:
		current_state.handle_command(type, target)
