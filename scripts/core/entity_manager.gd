extends Node

var _next_entity_id: int = 1
var _entities: Dictionary = {}
var _component_cache: Dictionary = {}

func spawn_entity(scene: PackedScene, parent: Node, position: Vector3) -> Node:
	var instance = scene.instantiate()

	# Assign ID for deterministic serialization
	var entity_id: int = _next_entity_id
	instance.set_meta("entity_id", entity_id)
	_next_entity_id += 1

	parent.add_child(instance)
	instance.global_position = position

	_entities[entity_id] = instance

	# Register components in cache
	_register_instance_components(entity_id, instance)

	return instance

func _register_instance_components(entity_id: int, instance: Node) -> void:
	if "health_component" in instance: register_component(entity_id, "HealthComponent")
	if "movement_component" in instance: register_component(entity_id, "MovementComponent")
	if "combat_component" in instance: register_component(entity_id, "CombatComponent")
	if "visibility_component" in instance: register_component(entity_id, "VisibilityComponent")
	if "gatherer_component" in instance: register_component(entity_id, "GathererComponent")

func register_component(entity_id: int, component_name: String) -> void:
	if not _component_cache.has(component_name):
		_component_cache[component_name] = []
	if entity_id not in _component_cache[component_name]:
		_component_cache[component_name].append(entity_id)

func unregister_entity_from_cache(entity_id: int) -> void:
	for component_name in _component_cache:
		var list: Array = _component_cache[component_name]
		if entity_id in list:
			list.erase(entity_id)

func get_entities_with_component(component_name: String) -> Array:
	return _component_cache.get(component_name, [])

func get_nodes_with_component(component_name: String) -> Array[Node]:
	var ids = _component_cache.get(component_name, [])
	var nodes: Array[Node] = []
	for id in ids:
		var node = _entities.get(id)
		if is_instance_valid(node):
			nodes.append(node)
	return nodes

func destroy_entity(entity: Node) -> void:
	if not is_instance_valid(entity): return

	if entity.has_meta("entity_id"):
		var entity_id: int = entity.get_meta("entity_id")
		_entities.erase(entity_id)
		unregister_entity_from_cache(entity_id)

	entity.queue_free()

func get_entity(id: int) -> Node:
	return _entities.get(id, null)

