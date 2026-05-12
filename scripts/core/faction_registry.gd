extends Node
# FactionRegistry: Manages factions and their relationships deterministically

enum Relation { NEUTRAL, ALLY, ENEMY }

var _factions: Dictionary = {} # id -> data
var _relations: Dictionary = {} # id1:id2 -> Relation
var _player_faction_id: int = 0

func register_faction(id: int, name: String, color: Color) -> void:
	_factions[id] = {
		"name": name,
		"color": color
	}

func set_relation(id1: int, id2: int, relation: Relation) -> void:
	var key = _get_relation_key(id1, id2)
	_relations[key] = relation

func get_relation(id1: int, id2: int) -> Relation:
	if id1 == id2: return Relation.ALLY
	var key = _get_relation_key(id1, id2)
	return _relations.get(key, Relation.NEUTRAL)

func is_enemy(id1: int, id2: int) -> bool:
	return get_relation(id1, id2) == Relation.ENEMY

func get_player_faction_id() -> int:
	return _player_faction_id

func set_player_faction_id(id: int) -> void:
	_player_faction_id = id

func _get_relation_key(id1: int, id2: int) -> String:
	var ids = [id1, id2]
	ids.sort()
	return str(ids[0]) + ":" + str(ids[1])
