extends Node

var _next_entity_id: int = 1
var _entities: Dictionary = {}
var _pool: Dictionary = {}

func acquire(scene: PackedScene, parent: Node, position: Vector3) -> Node:
	var path = scene.resource_path
	var instance: Node
	if _pool.has(path) and _pool[path].size() > 0:
		instance = _pool[path].pop_back()
	else:
		instance = scene.instantiate()
		instance.set_meta("scene_path", path)

	# Assign ID for deterministic serialization
	instance.set_meta("entity_id", _next_entity_id)
	_next_entity_id += 1

	parent.add_child(instance)
	if "global_position" in instance:
		instance.global_position = position

	_entities[instance.get_meta("entity_id")] = instance

	# Initialize components or systems if needed here
	return instance

func release(entity: Node) -> void:
	if not is_instance_valid(entity): return

	if entity.has_meta("entity_id"):
		_entities.erase(entity.get_meta("entity_id"))

	# Deactivate components from systems here
	# Let systems gracefully drop references

	if entity.get_parent():
		entity.get_parent().remove_child(entity)

	var path = entity.get_meta("scene_path", "")
	if path != "":
		if not _pool.has(path):
			_pool[path] = []
		_pool[path].append(entity)
	else:
		entity.queue_free()

func spawn_entity(scene: PackedScene, parent: Node, position: Vector3) -> Node:
	return acquire(scene, parent, position)

func destroy_entity(entity: Node) -> void:
	release(entity)

func get_entity(id: int) -> Node:
	return _entities.get(id, null)
