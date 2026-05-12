extends Node
# ReplayManager: Handles recording and playback of deterministic simulations

var is_recording: bool = false
var is_playing: bool = false

var replay_data = {
	"seed": 0,
	"commands": [] # Array of dictionaries: {tick, command_data}
}

func start_recording(initial_seed: int) -> void:
	replay_data.seed = initial_seed
	replay_data.commands = []
	is_recording = true
	is_playing = false

func record_command(tick: int, command: Dictionary) -> void:
	if not is_recording: return
	replay_data.commands.append({
		"tick": tick,
		"data": command
	})

func save_replay(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(replay_data))
		file.close()

func load_replay(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var json = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			replay_data = json.data
		file.close()

func play_replay() -> void:
	is_recording = false
	is_playing = true
	
	# 1. Reset Simulation
	var sim_manager = get_tree().root.get_node_or_null("Main/Systems/SimulationManager")
	if sim_manager:
		sim_manager.seed_simulation(replay_data.seed)
		# Clear existing state and prepare for playback
		_prepare_playback(sim_manager)

func _prepare_playback(sim_manager: Node) -> void:
	# Clear command buffer and queue recorded commands
	var buffer = sim_manager.command_buffer
	buffer.clear()
	for cmd in replay_data.commands:
		# Assuming deserialize_commands can handle this or we manually enqueue
		buffer.enqueue_serialized_command(cmd.tick, cmd.data)
