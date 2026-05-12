extends Node
class_name CommandSystem

func tick(_delta: float) -> void:
	pass

func process_commands(commands: Array) -> void:
	for cmd in commands:
		_execute_command(cmd)

func _execute_command(cmd: CommandBuffer.Command) -> void:
	print("CommandSystem: Executing ", cmd.command_type, " from ", cmd.issuer_id, " at tick ", cmd.tick)
	
	# Mapping commands to EventBus signals for system decoupling
	# This keeps CommandSystem focused on management and distribution
	match cmd.command_type:
		"move":
			# Find units issued by this commander (placeholder logic for now)
			# In a real implementation, we would query EntityManager for units owned by issuer_id
			var units: Array[Node] = []
			# Example: EventBus.command_issued.emit(units, "move", cmd.position)
			pass
		"attack":
			pass
		"gather":
			pass
