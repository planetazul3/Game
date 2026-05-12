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

var attack_range: float = 2.0
var attack_damage: int = 10
var attack_cooldown: float = 1.0
var attack_timer: float = 0.0

func _ready() -> void:
	target_position = global_position
	selection_ring.visible = false
	add_to_group("units")
	
	# Set faction color
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.BLUE if faction_id == 0 else Color.RED
	mesh.material_override = mat
	
	if faction_id != 0:
		var ring_mat = StandardMaterial3D.new()
		ring_mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
		ring_mat.albedo_color = Color.RED
		selection_ring.material_override = ring_mat

func _physics_process(delta: float) -> void:
	if hp <= 0:
		return

	selection_ring.visible = selected
	hp_bar.value = hp
	
	match current_state:
		State.IDLE:
			_process_idle(delta)
		State.MOVE:
			_process_move(delta)
		State.ATTACK:
			_process_attack(delta)

func move_to(pos: Vector3) -> void:
	# Add slight random offset to prevent perfect stacking
	var offset = Vector3(randf_range(-0.5, 0.5), 0, randf_range(-0.5, 0.5))
	target_position = pos + offset
	target_unit = null
	current_state = State.MOVE
	nav_agent.set_target_position(target_position)

func attack(target: Node3D) -> void:
	target_unit = target
	current_state = State.ATTACK

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		die()

func die() -> void:
	# Spawn explosion or just free
	queue_free()

func _process_idle(_delta: float) -> void:
	# Basic AI: scan for enemies
	var units = get_tree().get_nodes_in_group("units")
	var nearest_enemy = null
	var min_dist = 15.0
	
	for unit in units:
		if unit.faction_id != faction_id:
			var d = global_position.distance_to(unit.global_position)
			if d < min_dist:
				min_dist = d
				nearest_enemy = unit
	
	if nearest_enemy:
		attack(nearest_enemy)

func _process_move(delta: float) -> void:
	if nav_agent.is_navigation_finished():
		current_state = State.IDLE
		return

	var next_path_pos: Vector3 = nav_agent.get_next_path_position()
	var new_velocity: Vector3 = (next_path_pos - global_position).normalized() * speed
	
	# Separation
	var push = _calculate_separation()
	new_velocity += push * 3.0
	
	velocity = velocity.lerp(new_velocity, delta * 10.0)
	move_and_slide()
	
	if velocity.length() > 0.1:
		var look_target = global_position + velocity
		look_at(Vector3(look_target.x, global_position.y, look_target.z), Vector3.UP)

func _process_attack(delta: float) -> void:
	if not is_instance_valid(target_unit) or target_unit.hp <= 0:
		current_state = State.IDLE
		return
		
	var dist = global_position.distance_to(target_unit.global_position)
	if dist > attack_range:
		# Chase
		nav_agent.set_target_position(target_unit.global_position)
		_process_move(delta)
	else:
		# Attack
		attack_timer -= delta
		if attack_timer <= 0:
			target_unit.take_damage(attack_damage)
			attack_timer = attack_cooldown
			print("Unit ", name, " attacked ", target_unit.name)

func _calculate_separation() -> Vector3:
	var push = Vector3.ZERO
	var units = get_tree().get_nodes_in_group("units")
	for other in units:
		if other == self: continue
		var dist = global_position.distance_to(other.global_position)
		if dist < 1.5:
			push += (global_position - other.global_position).normalized() * (1.5 - dist)
	return push
