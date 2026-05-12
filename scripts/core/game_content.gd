extends Resource
class_name GameContent
# GameContent: Base class for all data-driven RTS assets

@export var guid: String = ""
@export var display_name: String = ""
@export var description: String = ""

func generate_guid() -> void:
	if guid == "":
		guid = str(Time.get_ticks_usec()) + "_" + str(randi())
