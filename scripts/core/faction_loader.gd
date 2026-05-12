extends Node

var factions: Dictionary = {}

func _ready() -> void:
	load_factions("res://data/factions/")

func load_factions(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".json"):
				var file_path = path + "/" + file_name
				var faction_data = _load_json(file_path)
				if faction_data:
					_validate_faction_data(file_name, faction_data)
					factions[faction_data["name"]] = faction_data
			file_name = dir.get_next()
	else:
		printerr("An error occurred when trying to access the path: ", path)

func _load_json(file_path: String) -> Dictionary:
	if not FileAccess.file_exists(file_path):
		return {}

	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		var data = json.data
		if typeof(data) == TYPE_DICTIONARY:
			return data
		else:
			printerr("JSON data at ", file_path, " is not a dictionary.")
			return {}
	else:
		printerr("JSON Parse Error: ", json.get_error_message(), " in ", file_path, " at line ", json.get_error_line())
		return {}

func _validate_faction_data(file_name: String, data: Dictionary) -> void:
	assert(data.has("name"), "Faction file " + file_name + " is missing 'name' key")
	assert(typeof(data["name"]) == TYPE_STRING, "Faction file " + file_name + " 'name' must be a string")

	assert(data.has("type"), "Faction file " + file_name + " is missing 'type' key")
	assert(typeof(data["type"]) == TYPE_STRING, "Faction file " + file_name + " 'type' must be a string")

	assert(data.has("traits"), "Faction file " + file_name + " is missing 'traits' key")
	assert(typeof(data["traits"]) == TYPE_ARRAY, "Faction file " + file_name + " 'traits' must be an array")

	assert(data.has("starting_units"), "Faction file " + file_name + " is missing 'starting_units' key")
	assert(typeof(data["starting_units"]) == TYPE_DICTIONARY, "Faction file " + file_name + " 'starting_units' must be a dictionary")

	assert(data.has("resources"), "Faction file " + file_name + " is missing 'resources' key")
	assert(typeof(data["resources"]) == TYPE_DICTIONARY, "Faction file " + file_name + " 'resources' must be a dictionary")
