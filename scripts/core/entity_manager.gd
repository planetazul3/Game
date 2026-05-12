extends Node

var _next_entity_id: int = 1
var _entities: Dictionary = {}

func spawn_entity(scene: PackedScene, parent: Node, position: Vector3) -> Node:
	var instance = scene.instantiate()

	# Assign ID for deterministic serialization
	instance.set_meta("entity_id", _next_entity_id)
	_next_entity_id += 1

	parent.add_child(instance)
	instance.global_position = position

	_entities[instance.get_meta("entity_id")] = instance

	# Initialize components or systems if needed here
	return instance

func destroy_entity(entity: Node) -> void:
	if not is_instance_valid(entity): return

	if entity.has_meta("entity_id"):
		_entities.erase(entity.get_meta("entity_id"))

	# Deactivate components from systems here
	# Let systems gracefully drop references

	entity.queue_free()

func get_entity(id: int) -> Node:
	return _entities.get(id, null)
