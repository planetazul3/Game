extends Node3D

var unit_scene = preload("res://scenes/units/unit.tscn")
var sim_manager: SimulationManager

enum TestScenario { A, B, C, DONE }
var current_scenario: TestScenario = TestScenario.A
var scenario_timer: float = 0.0
var scenario_duration: float = 5.0 # run each for 5 seconds

func _ready() -> void:
	print("--- Running Performance Tests ---")

	sim_manager = load("res://scripts/systems/simulation_manager.gd").new()
	sim_manager.name = "SimulationManager"
	add_child(sim_manager)

	_setup_scenario(current_scenario)

func _process(delta: float) -> void:
	scenario_timer -= delta
	if scenario_timer <= 0:
		_teardown_scenario()

		# Advance
		current_scenario += 1
		if current_scenario == TestScenario.DONE:
			print("--- Tests Complete ---")
			get_tree().quit()
		else:
			_setup_scenario(current_scenario)

func _setup_scenario(scenario: TestScenario) -> void:
	scenario_timer = scenario_duration
	print("Starting Scenario: ", scenario)

	var count = 0
	if scenario == TestScenario.A:
		count = 50
	elif scenario == TestScenario.B:
		count = 200
	elif scenario == TestScenario.C:
		count = 100 # Mix

	var start_time = Time.get_ticks_msec()

	for i in range(count):
		if unit_scene:
			var unit = EntityManager.spawn_entity(unit_scene, self, Vector3(DeterministicRandom.randf_range(-50, 50), 0, DeterministicRandom.randf_range(-50, 50)))

			if scenario == TestScenario.C:
				# Assign random movement targets
				var move_comp = unit.get_node_or_null("MovementComponent")
				if move_comp:
					move_comp.target_position = Vector3(DeterministicRandom.randf_range(-50, 50), 0, DeterministicRandom.randf_range(-50, 50))
					move_comp.has_target = true

	var end_time = Time.get_ticks_msec()
	print("Spawned ", count, " units in ", end_time - start_time, "ms. Simulating for ", scenario_duration, "s...")

func _teardown_scenario() -> void:
	var total_frames = Engine.get_frames_drawn()
	print("Average FPS during scenario: ", Engine.get_frames_per_second())

	for child in get_children():
		if child != sim_manager:
			EntityManager.destroy_entity(child)
