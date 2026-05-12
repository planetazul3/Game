extends Node
# EntityFactory: Centralized, deterministic entity construction

func spawn_unit(definition: Resource, position: Vector3, faction_id: int) -> Node:
	if not definition:
		push_error("EntityFactory: Cannot spawn unit without definition.")
		return null
	
	var prefab = definition.prefab_scene
	var instance: Node
	
	if prefab:
		instance = prefab.instantiate()
	else:
		# Fallback for headless tests or if prefab is missing
		var unit_script = load("res://scripts/units/unit.gd")
		instance = unit_script.new()
	
	# 1. Assign Definition and Faction
	if instance.has_method("set_definition"):
		instance.set_definition(definition)
	else:
		instance.set("definition", definition)
	
	if "faction_id" in instance:
		instance.set("faction_id", faction_id)
	
	# 2. Position
	if instance is Node3D:
		instance.global_position = position
		var move_comp = instance.get("movement_component")
		if move_comp:
			move_comp.simulation_position = position
	
	# 3. Register with EntityManager
	EntityManager.register_entity(instance)
	SpatialGrid.insert_entity(instance, position)
	
	# 4. Add to world
	var world = get_tree().root.get_node_or_null("Main/World/Units")
	if world:
		world.add_child(instance)
	else:
		get_tree().root.add_child(instance)
	
	return instance

func destroy_entity(entity: Node) -> void:
	if not is_instance_valid(entity): return
	
	# Unregister from systems first via EntityManager
	EntityManager.destroy_entity(entity)
	SpatialGrid.remove_entity(entity)
	
	# Node cleanup
	if entity.get_parent():
		entity.get_parent().remove_child(entity)
	entity.queue_free()

func register_entity(entity: Node) -> int:
	return EntityManager.register_entity(entity)
