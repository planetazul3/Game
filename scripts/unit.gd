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

@export var turn_speed: float = 10.0

func _ready() -> void:
	target_position = global_position
	selection_ring.visible = false
	UnitRegistry.register(self)
	add_to_group("units")
	
	print("Unit initialized: ", name, " Faction: ", faction_id)
	
	# Set faction color
	_original_material = StandardMaterial3D.new()
	_original_material.albedo_color = Color.BLUE if faction_id == 0 else Color.RED
	mesh.set_surface_override_material(0, _original_material)
	print("Material applied to ", name, " Color: ", _original_material.albedo_color)
	
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

func _exit_tree() -> void:
	UnitRegistry.unregister(self)

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

var is_attack_moving: bool = false

func move_to(pos: Vector3, attack_move: bool = false) -> void:
	var offset = Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0))
	target_position = pos + offset
	target_unit = null
	is_attack_moving = attack_move
	current_state = State.MOVE
	nav_agent.set_target_position(target_position)

func attack(target: Node3D) -> void:
	target_unit = target
	is_attack_moving = false
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
	mesh.set_surface_override_material(0, flash_mat)
	get_tree().create_timer(0.1).timeout.connect(func(): mesh.set_surface_override_material(0, _original_material))
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
	var units = UnitRegistry.units
	var nearest_enemy = null
	var min_dist = 30.0
	
	for unit in units:
		if is_instance_valid(unit) and unit.faction_id != faction_id:
			var d = global_position.distance_to(unit.global_position)
			if d < min_dist:
				min_dist = d
				nearest_enemy = unit
	
	if nearest_enemy:
		attack(nearest_enemy)

func _process_move(delta: float) -> void:
	if is_attack_moving:
		# Scan for enemies while moving
		var units = UnitRegistry.units
		for unit in units:
			if is_instance_valid(unit) and unit.faction_id != faction_id and global_position.distance_to(unit.global_position) < 15.0:
				attack(unit)
				return

	if nav_agent.is_navigation_finished():
		current_state = State.IDLE
		mesh.scale = mesh.scale.lerp(Vector3.ONE, delta * 15.0)
		return

	var next_path_pos: Vector3 = nav_agent.get_next_path_position()
	var new_velocity: Vector3 = (next_path_pos - global_position).normalized() * speed
	
	var push = _calculate_separation()
	new_velocity += push * 4.0
	
	# Mass-based acceleration
	velocity = velocity.lerp(new_velocity, delta * 6.0) 
	move_and_slide()
	
	# Procedural walk animation
	var walk_cycle = sin(Time.get_ticks_msec() * 0.015) * 0.1
	mesh.scale.y = 1.0 + walk_cycle
	mesh.scale.x = 1.0 - walk_cycle
	mesh.scale.z = 1.0 - walk_cycle
	
	if velocity.length() > 0.5:
		_smooth_look_at(global_position + velocity, delta)

func _process_attack(delta: float) -> void:
	if not is_instance_valid(target_unit) or target_unit.hp <= 0:
		current_state = State.IDLE
		return
		
	var dist = global_position.distance_to(target_unit.global_position)
	if dist > attack_range:
		nav_agent.set_target_position(target_unit.global_position)
		_process_move(delta)
	else:
		# Decelerate to stop
		velocity = velocity.lerp(Vector3.ZERO, delta * 15.0)
		move_and_slide()
		
		# Smoothly rotate to target
		_smooth_look_at(target_unit.global_position, delta)
		
		attack_timer -= delta
		
		# Attack Anticipation (Windup)
		if attack_timer < 0.2 and attack_timer > 0:
			mesh.scale = mesh.scale.lerp(Vector3(1.2, 0.8, 1.2), delta * 20.0)
		elif attack_timer <= 0:
			_fire_projectile()
			attack_timer = attack_cooldown
			mesh.scale = Vector3(0.8, 1.4, 0.8)
		else:
			mesh.scale = mesh.scale.lerp(Vector3.ONE, delta * 10.0)

func _fire_projectile() -> void:
	var bullet_scene = load("res://scenes/bullet.tscn")
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		get_tree().root.add_child(bullet)
		bullet.global_position = global_position + Vector3(0, 0.9, 0)
		bullet.target = target_unit
		bullet.damage = attack_damage

func _smooth_look_at(target_pos: Vector3, delta: float) -> void:
	var look_target = Vector3(target_pos.x, global_position.y, target_pos.z)
	if global_position.distance_to(look_target) < 0.1: return
	
	var target_transform = transform.looking_at(look_target, Vector3.UP)
	transform = transform.interpolate_with(target_transform, delta * turn_speed)

func _calculate_separation() -> Vector3:
	var push = Vector3.ZERO
	var units = UnitRegistry.units
	for other in units:
		if not is_instance_valid(other) or other == self: continue
		var dist = global_position.distance_to(other.global_position)
		if dist < 2.0:
			push += (global_position - other.global_position).normalized() * (2.0 - dist)
	return push
