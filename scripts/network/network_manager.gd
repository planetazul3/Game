extends Node
# NetworkManager: Handles server-authoritative command relay and lockstep sync

var is_server: bool = false
var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

func _ready() -> void:
	# CLI Parsing
	var args = OS.get_cmdline_args()
	if "--server" in args:
		start_server()

func start_server() -> void:
	is_server = true
	peer.create_server(4242)
	multiplayer.multiplayer_peer = peer
	print("NetworkManager: Dedicated server started on port 4242")
	
	# Disable visual-only systems
	_disable_visual_systems()

func _disable_visual_systems() -> void:
	var fow = get_tree().root.get_node_or_null("Main/Systems/FogOfWarManager")
	if fow: fow.set_process(false)
	
	# We could also hide all meshes in the scene for performance
	print("NetworkManager: Visual systems disabled for headless mode")

@rpc("any_peer")
func submit_command(tick: int, command_data: Dictionary) -> void:
	if not is_server: return
	
	# Server validates and relays the command to all clients for a future tick
	# In a true lockstep, the server decides which tick a command executes
	var sim_mgr = get_tree().root.get_node_or_null("Main/Systems/SimulationManager")
	var current_tick = 0
	if sim_mgr:
		current_tick = sim_mgr.current_tick
		
	var execution_tick = max(current_tick + 2, tick)
	rpc("execute_command", execution_tick, command_data)

@rpc("authority")
func execute_command(tick: int, command_data: Dictionary) -> void:
	# Add to simulation command buffer
	var sim_mgr = get_tree().root.get_node_or_null("Main/Systems/SimulationManager")
	if sim_mgr:
		sim_mgr.command_buffer.add_command(tick, command_data)
