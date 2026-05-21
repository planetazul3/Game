extends CharacterBody3D

@export var hp: int = 100
@export var max_hp: int = 100
@export var speed: float = 5.0
@export var faction_id: int = 0 # 0 = player, 1 = enemy

var selected: bool = false
var target_position: Vector3
var target_unit: Node3D = null

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var selection_ring: MeshInstance3D = $SelectionRing
@onready var hp_bar: ProgressBar = $SubViewport/ProgressBar
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var hp_sprite: Sprite3D = $Sprite3D

enum State { IDLE, MOVE, ATTACK }
var current_state: State = State.IDLE

@export var attack_range: float = 8.0
@export var attack_damage: int = 10
@export var attack_cooldown: float = 1.0
var attack_timer: float = 0.0
var hp_fill_stylebox: StyleBoxFlat
var hp_bg_stylebox: StyleBoxFlat

var _original_material: StandardMaterial3D

@export var turn_speed: float = 10.0
@export var auto_aggro_range: float = 10.0 # Only auto-attack nearby enemies

# Visual colors per faction
const PLAYER_COLOR := Color(0.15, 0.45, 0.95) # Rich blue
const PLAYER_COLOR_HIGHLIGHT := Color(0.3, 0.6, 1.0)
const ENEMY_COLOR := Color(0.9, 0.15, 0.15) # Vivid red
const ENEMY_COLOR_HIGHLIGHT := Color(1.0, 0.3, 0.2)
const PLAYER_RING_COLOR := Color(0.2, 1.0, 0.4, 1.0)
const ENEMY_RING_COLOR := Color(1.0, 0.2, 0.2, 1.0)

func _ready() -> void:
	target_position = global_position
	selection_ring.visible = false
	max_hp = hp
	UnitRegistry.register(self)
	add_to_group("units")
	
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	
	# HP bar styling
	hp_fill_stylebox = StyleBoxFlat.new()
	hp_bar.add_theme_stylebox_override("fill", hp_fill_stylebox)
	hp_bg_stylebox = StyleBoxFlat.new()
	hp_bg_stylebox.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	hp_bg_stylebox.corner_radius_top_left = 2
	hp_bg_stylebox.corner_radius_top_right = 2
	hp_bg_stylebox.corner_radius_bottom_left = 2
	hp_bg_stylebox.corner_radius_bottom_right = 2
	hp_bar.add_theme_stylebox_override("background", hp_bg_stylebox)
	
	# Set faction color with proper materials
	_original_material = StandardMaterial3D.new()
	if faction_id == 0:
		_original_material.albedo_color = PLAYER_COLOR
		_original_material.emission_enabled = true
		_original_material.emission = PLAYER_COLOR * 0.3
		_original_material.emission_energy_multiplier = 0.5
	else:
		_original_material.albedo_color = ENEMY_COLOR
		_original_material.emission_enabled = true
		_original_material.emission = ENEMY_COLOR * 0.3
		_original_material.emission_energy_multiplier = 0.5
	
	_original_material.roughness = 0.3
	_original_material.metallic = 0.2
	mesh.set_surface_override_material(0, _original_material)
	
	# Selection ring materials
	var ring_mat = StandardMaterial3D.new()
	ring_mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	ring_mat.emission_enabled = true
	ring_mat.emission_energy_multiplier = 2.5
	if faction_id != 0:
		ring_mat.albedo_color = ENEMY_RING_COLOR
		ring_mat.emission = ENEMY_RING_COLOR
	else:
		ring_mat.albedo_color = PLAYER_RING_COLOR
		ring_mat.emission = PLAYER_RING_COLOR
	selection_ring.material_override = ring_mat

func _exit_tree() -> void:
	UnitRegistry.unregister(self)

var last_damage_time: float = -10.0
var _nav_ready: bool = false
var _nav_startup: float = 0.5

func _physics_process(delta: float) -> void:
	if hp <= 0:
		return
	
	# Wait for NavigationServer to sync before any nav queries
	if not _nav_ready:
		_nav_startup -= delta
		if _nav_startup <= 0:
			_nav_ready = true
		else:
			_update_hp_bar(delta)
			return

	selection_ring.visible = selected
	_update_hp_bar(delta)
	
	match current_state:
		State.IDLE:
			_process_idle(delta)
		State.MOVE:
			_process_move(delta)
		State.ATTACK:
			_process_attack(delta)

func _update_hp_bar(_delta: float) -> void:
	hp_bar.value = float(hp) / float(max_hp) * 100.0
	
	var hp_ratio := float(hp) / float(max_hp)
	var color: Color
	if hp_ratio < 0.3:
		color = Color(0.9, 0.1, 0.1) # Red
	elif hp_ratio < 0.6:
		color = Color(1.0, 0.7, 0.1) # Orange-yellow
	else:
		color = Color(0.2, 0.9, 0.3) # Green
	
	hp_fill_stylebox.bg_color = color
	hp_fill_stylebox.corner_radius_top_left = 2
	hp_fill_stylebox.corner_radius_top_right = 2
	hp_fill_stylebox.corner_radius_bottom_left = 2
	hp_fill_stylebox.corner_radius_bottom_right = 2
	
	# Show HP bar when selected, recently damaged, or not full HP
	var time_since_damage = Time.get_ticks_msec() / 1000.0 - last_damage_time
	var should_show = selected or time_since_damage < 3.0 or hp < max_hp
	hp_sprite.visible = should_show

var is_attack_moving: bool = false

func move_to(pos: Vector3, attack_move: bool = false) -> void:
	var index := 0
	if selected:
		var controller = get_tree().get_first_node_in_group("player_controller")
		if controller:
			index = controller.selected_units.find(self)
			if index == -1: index = 0

	var spacing = 2.0
	var row = index / 4
	var col = index % 4
	var formation_offset = Vector3((col - 1.5) * spacing, 0, row * spacing)

	target_position = pos + formation_offset
	target_unit = null
	is_attack_moving = attack_move
	current_state = State.MOVE
	nav_agent.set_target_position(target_position)

func attack(target: Node3D) -> void:
	target_unit = target
	is_attack_moving = false
	current_state = State.ATTACK

func take_damage(amount: int, source_pos: Vector3 = Vector3.ZERO) -> void:
	hp -= amount
	last_damage_time = Time.get_ticks_msec() / 1000.0
	_flash_damage()
	
	# Hit knockback
	if source_pos != Vector3.ZERO:
		var dir = (global_position - source_pos).normalized()
		velocity += dir * 3.0
		_kick_scale(Vector3(1.2, 0.7, 1.2))
	
	# Auto-retaliate if idle
	if current_state == State.IDLE and source_pos != Vector3.ZERO:
		var attacker = _get_nearest_enemy(auto_aggro_range)
		if attacker:
			attack(attacker)
	
	if hp <= 0:
		die()

func _kick_scale(s: Vector3) -> void:
	mesh.scale = s

func _flash_damage() -> void:
	var flash_mat = StandardMaterial3D.new()
	flash_mat.albedo_color = Color.WHITE
	flash_mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	flash_mat.emission_enabled = true
	flash_mat.emission = Color.WHITE
	flash_mat.emission_energy_multiplier = 3.0
	mesh.set_surface_override_material(0, flash_mat)
	get_tree().create_timer(0.08).timeout.connect(func(): 
		if is_instance_valid(self):
			mesh.set_surface_override_material(0, _original_material)
	)
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

func _get_nearest_enemy(max_dist: float) -> Node3D:
	var nearest = null
	var min_dist = max_dist
	for unit in UnitRegistry.units:
		if unit == self: continue
		if not is_instance_valid(unit): continue
		if unit.faction_id == faction_id: continue
		if unit.hp <= 0: continue
		var d = global_position.distance_to(unit.global_position)
		if d < min_dist:
			min_dist = d
			nearest = unit
	return nearest

func _process_idle(delta: float) -> void:
	mesh.scale = mesh.scale.lerp(Vector3.ONE, delta * 5.0)
	# Only auto-aggro at shorter defensive range
	var enemy = _get_nearest_enemy(auto_aggro_range)
	if enemy:
		attack(enemy)

func _process_move(delta: float) -> void:
	if is_attack_moving:
		var enemy = _get_nearest_enemy(auto_aggro_range)
		if enemy:
			attack(enemy)
			return

	if nav_agent.is_navigation_finished():
		current_state = State.IDLE
		nav_agent.set_velocity(Vector3.ZERO)
		return

	var next_path_pos: Vector3 = nav_agent.get_next_path_position()
	var new_velocity: Vector3 = (next_path_pos - global_position).normalized() * speed
	
	var push = _calculate_separation()
	new_velocity += push * 5.0
	
	nav_agent.set_velocity(new_velocity)
	
	# Procedural walk animation
	var walk_cycle = sin(Time.get_ticks_msec() * 0.015) * 0.08
	mesh.scale.y = 1.0 + walk_cycle
	mesh.scale.x = 1.0 - walk_cycle * 0.5
	mesh.scale.z = 1.0 - walk_cycle * 0.5
	
	if velocity.length() > 0.5:
		_smooth_look_at(global_position + velocity, delta)

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.lerp(safe_velocity, 0.15)
	move_and_slide()

func _process_attack(delta: float) -> void:
	if not is_instance_valid(target_unit) or target_unit.hp <= 0:
		# Look for a new target before going idle
		var new_target = _get_nearest_enemy(auto_aggro_range)
		if new_target:
			target_unit = new_target
		else:
			current_state = State.IDLE
		return
		
	var dist = global_position.distance_to(target_unit.global_position)
	if dist > attack_range:
		nav_agent.set_target_position(target_unit.global_position)
		_process_move(delta)
	else:
		velocity = velocity.lerp(Vector3.ZERO, delta * 10.0)
		move_and_slide()
		nav_agent.set_velocity(Vector3.ZERO)
		
		_smooth_look_at(target_unit.global_position, delta)
		
		attack_timer -= delta
		
		if attack_timer < attack_cooldown * 0.35 and attack_timer > 0:
			mesh.scale = mesh.scale.lerp(Vector3(1.3, 0.7, 1.3), delta * 20.0)
		elif attack_timer <= 0:
			_fire_projectile()
			_play_sound("res://assets/sounds/shoot.wav")
			attack_timer = attack_cooldown
			mesh.scale = Vector3(1.5, 0.5, 1.5)
		else:
			mesh.scale = mesh.scale.lerp(Vector3.ONE, delta * 5.0)

func _fire_projectile() -> void:
	var bullet_scene = load("res://scenes/bullet.tscn")
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		get_tree().root.add_child(bullet)
		bullet.global_position = global_position + Vector3(0, 0.9, 0)
		bullet.target = target_unit
		bullet.damage = attack_damage
		bullet.source_unit = self
		# Set bullet color based on faction
		if faction_id == 0:
			bullet.set_color(Color(0.3, 0.6, 1.0)) # Blue projectile for player
		else:
			bullet.set_color(Color(1.0, 0.3, 0.2)) # Red projectile for enemy

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
		if dist < 1.8:
			push += (global_position - other.global_position).normalized() * (1.8 - dist)
	return push

func on_selected() -> void:
	selected = true
	# Selection pop effect
	mesh.scale = Vector3(1.3, 0.7, 1.3)

func on_deselected() -> void:
	selected = false
