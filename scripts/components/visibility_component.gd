extends Node
class_name VisibilityComponent

enum VisibilityState {
	UNEXPLORED,
	EXPLORED,
	VISIBLE
}

@export var faction_id: int = 0
@export var vision_range: float = 15.0

# Current logical state (often relative to the local player's faction in a vertical slice)
var state: VisibilityState = VisibilityState.UNEXPLORED

# Used by the visibility system to optimize distance checks
var grid_cell: Vector2i = Vector2i.ZERO
