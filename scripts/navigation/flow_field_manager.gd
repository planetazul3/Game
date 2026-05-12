extends Node
# FlowFieldManager: Manages and caches flow fields for different destinations

@export var field_width: int = 100
@export var field_height: int = 100
@export var cell_size: float = 1.0

var CostFieldClass = load("res://scripts/navigation/cost_field.gd")
var IntegrationFieldClass = load("res://scripts/navigation/integration_field.gd")
var FlowFieldClass = load("res://scripts/navigation/flow_field.gd")

var cost_field
var flow_field_cache: Dictionary = {} # Vector2i (destination) -> FlowField

func _ready() -> void:
	cost_field = CostFieldClass.new(field_width, field_height, cell_size)

func get_flow_field(destination: Vector3) -> RefCounted:
	var dest_grid = cost_field.world_to_grid(destination)
	
	if flow_field_cache.has(dest_grid):
		return flow_field_cache[dest_grid]
		
	# Generate new field
	var integration = IntegrationFieldClass.new(field_width, field_height)
	integration.generate(dest_grid.x, dest_grid.y, cost_field)
	
	var flow = FlowFieldClass.new(field_width, field_height)
	flow.generate(integration)
	
	flow_field_cache[dest_grid] = flow
	return flow

func world_to_grid(world_pos: Vector3) -> Vector2i:
	return cost_field.world_to_grid(world_pos)
