extends Node
class_name ResourceSystem

var resources: Dictionary = {
	"energy": 0,
	"minerals": 0
}

func _ready() -> void:
	pass

func tick(delta: float) -> void:
	var scene_units = get_tree().get_nodes_in_group("selectable")
	for sel in scene_units:
		var entity = sel.get_parent()
		if not is_instance_valid(entity): continue

		var gather_comp = entity.get_node_or_null("GathererComponent")
		if not gather_comp or not is_instance_valid(gather_comp.target_resource): continue

		var target = gather_comp.target_resource
		var distance = entity.global_position.distance_to(target.global_position)

		if distance <= gather_comp.gather_range:
			gather_comp.gather_timer += delta
			if gather_comp.gather_timer >= gather_comp.gather_interval:
				_gather(gather_comp, target)
				gather_comp.gather_timer = 0.0

func _gather(comp: Node, target: Node) -> void:
	if target.has_method("extract"):
		var extracted = target.extract(comp.gather_rate)
		var type = target.resource_type if "resource_type" in target else "energy"

		if resources.has(type):
			resources[type] += extracted
			EventBus._track_event_throughput()
			EventBus.resource_collected.emit(type, extracted)

func spend_resource(type: String, amount: int) -> bool:
	if resources.has(type) and resources[type] >= amount:
		resources[type] -= amount
		return true
	return false
