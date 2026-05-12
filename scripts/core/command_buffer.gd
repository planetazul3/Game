extends Node
class_name CommandBuffer

# Command structure for deterministic simulation
class Command extends RefCounted:
	var tick: int
	var issuer_id: int
	var target_id: int
	var command_type: String
	var position: Vector3
	var metadata: Dictionary

	func _init(p_tick: int, p_issuer: int, p_target: int, p_type: String, p_pos: Vector3, p_meta: Dictionary = {}):
		tick = p_tick
		issuer_id = p_issuer
		target_id = p_target
		command_type = p_type
		position = p_pos
		metadata = p_meta

	func to_dict() -> Dictionary:
		return {
			"t": tick,
			"i": issuer_id,
			"tg": target_id,
			"type": command_type,
			"p": [position.x, position.y, position.z],
			"m": metadata
		}

	static func from_dict(d: Dictionary) -> Command:
		var pos = Vector3(d["p"][0], d["p"][1], d["p"][2])
		return Command.new(d["t"], d["i"], d["tg"], d["type"], pos, d["m"])

# Stores commands indexed by tick
# _pending_commands[tick] = Array[Command]
var _pending_commands: Dictionary = {}

func enqueue_command(cmd: Command) -> void:
	if not _pending_commands.has(cmd.tick):
		_pending_commands[cmd.tick] = []
	
	_pending_commands[cmd.tick].append(cmd)
	
	# Ensure deterministic sorting within the tick
	# Sorting by issuer_id, then type, then target_id for stability
	_pending_commands[cmd.tick].sort_custom(
		func(a: Command, b: Command):
			if a.issuer_id != b.issuer_id:
				return a.issuer_id < b.issuer_id
			if a.command_type != b.command_type:
				return a.command_type < b.command_type
			return a.target_id < b.target_id
	)

func consume_tick_commands(tick: int) -> Array[Command]:
	var commands: Array[Command] = []
	if _pending_commands.has(tick):
		# Explicitly cast to typed array for Godot 4 consistency
		for cmd in _pending_commands[tick]:
			commands.append(cmd)
		_pending_commands.erase(tick)
	return commands

func serialize_commands() -> PackedByteArray:
	var data = []
	# Sort ticks to ensure deterministic serialization
	var sorted_ticks = _pending_commands.keys()
	sorted_ticks.sort()
	
	for t in sorted_ticks:
		for cmd in _pending_commands[t]:
			data.append(cmd.to_dict())
	
	return var_to_bytes(data)

func deserialize_commands(buffer: PackedByteArray) -> void:
	var data = bytes_to_var(buffer)
	if typeof(data) != TYPE_ARRAY:
		push_error("CommandBuffer: Failed to deserialize commands. Invalid data format.")
		return
	
	_pending_commands.clear()
	for d in data:
		var cmd = Command.from_dict(d)
		enqueue_command(cmd)

func clear() -> void:
	_pending_commands.clear()
