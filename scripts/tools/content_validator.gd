@tool
extends Node
# ContentValidator: Automated validation for data-driven RTS content

func validate_all_content() -> Dictionary:
	var results = {
		"valid": true,
		"errors": [],
		"warnings": []
	}
	
	var data_paths = [
		"res://data/buildings/",
		"res://data/tech/",
		"res://data/abilities/",
		"res://data/biomes/"
	]
	
	var seen_ids = {}
	
	for path in data_paths:
		_scan_dir(path, seen_ids, results)
		
	return results

func _scan_dir(path: String, seen_ids: Dictionary, results: Dictionary) -> void:
	var dir = DirAccess.open(path)
	if not dir: return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			_validate_file(path + file_name, seen_ids, results)
		file_name = dir.get_next()

func _validate_file(file_path: String, seen_ids: Dictionary, results: Dictionary) -> void:
	var res = load(file_path)
	if not res:
		results.errors.append("Failed to load: " + file_path)
		results.valid = false
		return
		
	# Check for GUID-based content ID
	if not res.get("guid"):
		results.errors.append("Missing GUID in: " + file_path)
		results.valid = false
	else:
		var guid = res.guid
		if seen_ids.has(guid):
			results.errors.append("Duplicate GUID detected: " + guid + " in " + file_path + " and " + seen_ids[guid])
			results.valid = false
		else:
			seen_ids[guid] = file_path

	# Check for circular tech trees (simplified stub)
	if res.get("prerequisites"):
		for prereq in res.prerequisites:
			if prereq == res:
				results.errors.append("Circular dependency detected in: " + file_path)
				results.valid = false
