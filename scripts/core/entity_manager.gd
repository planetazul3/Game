extends Node

var _next_entity_id: int = 1
var _entities: Dictionary = {}

func register_entity(instance: Node) -> int:
	# Assign ID for deterministic serialization
	var entity_id: int = _next_entity_id
	instance.set_meta("entity_id", entity_id)
	_next_entity_id += 1

	_entities[entity_id] = instance

	# Register components in cache
	_register_instance_components(entity_id, instance)

	return entity_id

func _register_instance_components(entity_id: int, instance: Node) -> void:
	var components = ["health_component", "movement_component", "combat_component", "visibility_component", "gatherer_component", "ai_component"]
	for comp_name in components:
		if comp_name in instance:
			var component = instance.get(comp_name)
			if component is RefCounted:
				# Convert snake_case to PascalCase for the registry
				var registry_name = comp_name.to_camel_case().capitalize().replace(" ", "")
				ComponentRegistry.register_component(entity_id, registry_name, component)

func unregister_entity_from_cache(entity_id: int) -> void:
	ComponentRegistry.remove_all_components(entity_id)

func get_entities_with_component(component_name: String) -> Array:
	# Return IDs for backward compatibility if needed, but registry returns components
	# Systems will be refactored to use ComponentRegistry directly
	var components = ComponentRegistry.get_components_by_type(component_name)
	var ids = []
	for comp in components:
		ids.append(ComponentRegistry.get_owner_id(comp))
	return ids

func get_nodes_with_component(component_name: String) -> Array[Node]:
	var components = ComponentRegistry.get_components_by_type(component_name)
	var nodes: Array[Node] = []
	for comp in components:
		var entity_id = ComponentRegistry.get_owner_id(comp)
		var node = _entities.get(entity_id)
		if is_instance_valid(node):
			nodes.append(node)
	return nodes

func destroy_entity(entity: Node) -> void:
	if not is_instance_valid(entity): return

	if entity.has_meta("entity_id"):
		var entity_id: int = entity.get_meta("entity_id")
		_entities.erase(entity_id)
		unregister_entity_from_cache(entity_id)

func get_entity(id: int) -> Node:
	return _entities.get(id, null)

func get_all_entities() -> Dictionary:
	return _entities

func clear_all_entities() -> void:
	for id in _entities:
		var entity = _entities[id]
		if is_instance_valid(entity):
			entity.queue_free()
	_entities.clear()
	ComponentRegistry.clear_all()
	_next_entity_id = 1

