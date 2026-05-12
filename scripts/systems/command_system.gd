extends Node
class_name CommandSystem

func tick(_delta: float) -> void:
	pass

func process_commands(commands: Array) -> void:
	for cmd in commands:
		_execute_command(cmd)

func _execute_command(cmd: CommandBuffer.Command) -> void:
	print("CommandSystem: Executing ", cmd.command_type, " from ", cmd.issuer_id, " at tick ", cmd.tick)
	
	# In a real implementation, we'd find units by issuer_id
	# For now, we assume a single selection or similar
	var entities = EntityManager.get_nodes_with_component("AIComponent")
	var ai_system = get_parent().get_node_or_null("AISystem")
	
	for entity in entities:
		# Filter by faction/issuer logic would go here
		if ai_system:
			ai_system.handle_unit_command(entity, cmd.command_type, cmd.position if cmd.command_type == "move" else cmd.target_id)
