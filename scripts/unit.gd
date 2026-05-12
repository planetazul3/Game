extends CharacterBody3D

@export var hp: int = 100
@export var speed: float = 5.0
@export var faction_id: int = 0 # 0 = player, 1 = enemy

var selected: bool = false
var target_position: Vector3
var target_unit: Node3D = null

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var selection_ring: MeshInstance3D = $SelectionRing
@onready var hp_bar: ProgressBar = $SubViewport/ProgressBar
@onready var mesh: MeshInstance3D = $MeshInstance3D

enum State { IDLE, MOVE, ATTACK }
var current_state: State = State.IDLE

@export var attack_range: float = 8.0 # Ranged combat
@export var attack_damage: int = 10
@export var attack_cooldown: float = 1.0
var attack_timer: float = 0.0

var _original_material: StandardMaterial3D

func _ready() -> void:
	target_position = global_position
	selection_ring.visible = false
	add_to_group("units")
	
	# Set faction color
	_original_material = StandardMaterial3D.new()
	_original_material.albedo_color = Color.BLUE if faction_id == 0 else Color.RED
	mesh.material_override = _original_material
	
	if faction_id != 0:
		var ring_mat = StandardMaterial3D.new()
		ring_mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
		ring_mat.albedo_color = Color.RED
		ring_mat.emission_enabled = true
		ring_mat.emission = Color.RED
		ring_mat.emission_energy_multiplier = 2.0
		selection_ring.material_override = ring_mat
	else:
		var ring_mat = StandardMaterial3D.new()
		ring_mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
		ring_mat.albedo_color = Color.GREEN
		ring_mat.emission_enabled = true
		ring_mat.emission = Color.GREEN
		ring_mat.emission_energy_multiplier = 2.0
		selection_ring.material_override = ring_mat

func _physics_process(delta: float) -> void:
	if hp <= 0:
		return

	selection_ring.visible = selected
	_update_hp_bar()
	
	match current_state:
		State.IDLE:
			_process_idle(delta)
		State.MOVE:
			_process_move(delta)
		State.ATTACK:
			_process_attack(delta)

func _update_hp_bar() -> void:
	hp_bar.value = hp
	var color = Color.GREEN
	if hp < 40: color = Color.RED
	elif hp < 75: color = Color.YELLOW
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = color
	hp_bar.add_theme_stylebox_override("fill", sb)

func move_to(pos: Vector3) -> void:
	var offset = Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0))
	target_position = pos + offset
	target_unit = null
	current_state = State.MOVE
	nav_agent.set_target_position(target_position)

func attack(target: Node3D) -> void:
	target_unit = target
	current_state = State.ATTACK

func take_damage(amount: int) -> void:
	hp -= amount
	_flash_damage()
	if hp <= 0:
		die()

func _flash_damage() -> void:
	var flash_mat = StandardMaterial3D.new()
	flash_mat.albedo_color = Color.WHITE
	flash_mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	mesh.material_override = flash_mat
	get_tree().create_timer(0.1).timeout.connect(func(): mesh.material_override = _original_material)
	_play_sound("res://assets/sounds/hit.wav")

func die() -> void:
	var parts_scene = load("res://scenes/death_particles.tscn")
	if parts_scene:
		var parts = parts_scene.instantiate()
		get_tree().root.add_child(parts)
		parts.global_position = global_position
	_play_sound("res://assets/sounds/death.wav")
	queue_free()

func _play_sound(path: String) -> void:
	if not ResourceLoader.exists(path):
		return
		
	var sfx = AudioStreamPlayer3D.new()
	var stream = load(path)
	if stream:
		sfx.stream = stream
		get_tree().root.add_child(sfx)
		sfx.global_position = global_position
		sfx.play()
		sfx.finished.connect(sfx.queue_free)

func _process_idle(_delta: float) -> void:
	var units = get_tree().get_nodes_in_group("units")
	var nearest_enemy = null
	var min_dist = 30.0 # Increased from 15.0
	
	for unit in units:
		if unit.faction_id != faction_id:
			var d = global_position.distance_to(unit.global_position)
			if d < min_dist:
				min_dist = d
				nearest_enemy = unit
	
	if nearest_enemy:
		print("Unit ", name, " (Faction ", faction_id, ") spotted enemy ", nearest_enemy.name)
		attack(nearest_enemy)

func _process_move(delta: float) -> void:
	if nav_agent.is_navigation_finished():
		current_state = State.IDLE
		mesh.scale = mesh.scale.lerp(Vector3.ONE, delta * 10.0) # Reset scale
		return

	var next_path_pos: Vector3 = nav_agent.get_next_path_position()
	var new_velocity: Vector3 = (next_path_pos - global_position).normalized() * speed
	
	var push = _calculate_separation()
	new_velocity += push * 4.0
	
	velocity = velocity.lerp(new_velocity, delta * 8.0)
	move_and_slide()
	
	# Procedural "Running" animation (Squish/Stretch)
	var walk_cycle = sin(Time.get_ticks_msec() * 0.015) * 0.1
	mesh.scale.y = 1.0 + walk_cycle
	mesh.scale.x = 1.0 - walk_cycle
	mesh.scale.z = 1.0 - walk_cycle
	
	if velocity.length() > 0.5:
		var look_target = global_position + velocity
		look_at(Vector3(look_target.x, global_position.y, look_target.z), Vector3.UP)

func _process_attack(delta: float) -> void:
	if not is_instance_valid(target_unit) or target_unit.hp <= 0:
		current_state = State.IDLE
		return
		
	var dist = global_position.distance_to(target_unit.global_position)
	if dist > attack_range:
		nav_agent.set_target_position(target_unit.global_position)
		_process_move(delta)
	else:
		velocity = velocity.lerp(Vector3.ZERO, delta * 10.0)
		move_and_slide()
		
		attack_timer -= delta
		if attack_timer <= 0:
			_fire_projectile()
			attack_timer = attack_cooldown

func _fire_projectile() -> void:
	var bullet_scene = load("res://scenes/bullet.tscn")
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		get_tree().root.add_child(bullet)
		bullet.global_position = global_position + Vector3(0, 0.9, 0)
		bullet.target = target_unit
		bullet.damage = attack_damage

func _calculate_separation() -> Vector3:
	var push = Vector3.ZERO
	var units = get_tree().get_nodes_in_group("units")
	for other in units:
		if other == self: continue
		var dist = global_position.distance_to(other.global_position)
		if dist < 2.0:
			push += (global_position - other.global_position).normalized() * (2.0 - dist)
	return push
