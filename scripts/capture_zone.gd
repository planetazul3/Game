extends Area3D

@export var capture_time := 15.0

var timer := 0.0

func _physics_process(delta):
	var player_units := 0
	var enemy_units := 0

	for body in get_overlapping_bodies():
		if not body.is_in_group("units"):
			continue

		if body.faction_id == 0:
			player_units += 1
		else:
			enemy_units += 1

	if player_units > enemy_units:
		timer += delta
		print("Capturing... ", int(timer), "/", int(capture_time))
	elif enemy_units > player_units:
		timer = max(timer - delta, 0.0)
	
	if timer >= capture_time:
		print("PLAYER WINS")
		# Optional: Add victory signal or scene change
