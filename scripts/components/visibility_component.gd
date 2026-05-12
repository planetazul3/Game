extends RefCounted
class_name VisibilityComponent

enum VisibilityState {
    UNEXPLORED,
    EXPLORED,
    VISIBLE
}

var current_state: VisibilityState = VisibilityState.UNEXPLORED
var grid_cell: Vector2i = Vector2i.ZERO
var vision_range: float = 10.0
var faction_id: int = 0
