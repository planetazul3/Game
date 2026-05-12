extends Node
# ComponentRegistry: High-performance O(1) component storage and lookup

# _components_by_type[type_name] = [component1, component2, ...]
var _components_by_type: Dictionary = {}

# _entity_components[entity_id] = {type_name: component_instance}
var _entity_components: Dictionary = {}

# _component_owners[component_instance] = entity_id
var _component_owners: Dictionary = {}

func register_component(entity_id: int, type_name: String, component: RefCounted) -> void:
	if not _components_by_type.has(type_name):
		_components_by_type[type_name] = []
	
	if not _entity_components.has(entity_id):
		_entity_components[entity_id] = {}
	
	_components_by_type[type_name].append(component)
	_entity_components[entity_id][type_name] = component
	_component_owners[component] = entity_id

func remove_component(entity_id: int, type_name: String) -> void:
	if not _entity_components.has(entity_id): return
	
	var components = _entity_components[entity_id]
	if components.has(type_name):
		var component = components[type_name]
		_components_by_type[type_name].erase(component)
		_component_owners.erase(component)
		components.erase(type_name)

func remove_all_components(entity_id: int) -> void:
	if not _entity_components.has(entity_id): return
	
	var components = _entity_components[entity_id]
	for type_name in components.keys():
		remove_component(entity_id, type_name)
	
	_entity_components.erase(entity_id)

func get_components_by_type(type_name: String) -> Array:
	return _components_by_type.get(type_name, [])

func get_entity_components(entity_id: int) -> Dictionary:
	return _entity_components.get(entity_id, {})

func get_owner_id(component: RefCounted) -> int:
	return _component_owners.get(component, -1)

func clear_all() -> void:
	_components_by_type.clear()
	_entity_components.clear()
	_component_owners.clear()
