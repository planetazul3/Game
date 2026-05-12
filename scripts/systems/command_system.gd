extends Node
class_name CommandSystem

func tick(_delta: float) -> void:
	pass

func process_commands(commands: Array) -> void:
	for cmd in commands:
		_execute_command(cmd)

func _execute_command(cmd: CommandBuffer.Command) -> void:
	# Find the specific unit by its target_id (reusing target_id as the subject for now)
	var unit = EntityManager.get_entity(cmd.target_id)
	if not is_instance_valid(unit):
		return
		
	# Verify faction authorization
	if unit.get("faction_id") != cmd.issuer_id:
		return
		
	var ai_system = get_parent().get_node_or_null("AISystem")
	if ai_system:
		ai_system.handle_unit_command(unit, cmd.command_type, cmd.position if cmd.command_type == "move" else cmd.target_id)
