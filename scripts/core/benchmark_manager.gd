extends Node
# BenchmarkManager: Automates deterministic performance stress tests

var benchmarks = [100, 250, 500, 1000]
var current_benchmark_idx = -1
var benchmark_running = false
var benchmark_ticks = 300 # 10 seconds at 30Hz

var results = []

func run_next_benchmark() -> void:
	current_benchmark_idx += 1
	if current_benchmark_idx >= benchmarks.size():
		_print_results()
		return
		
	var unit_count = benchmarks[current_benchmark_idx]
	_setup_scenario(unit_count)
	benchmark_running = true

func _setup_scenario(count: int) -> void:
	# 1. Reset Simulation
	var sim_manager = get_tree().root.get_node_or_null("Main/Systems/SimulationManager")
	if sim_manager:
		sim_manager.load_simulation({"tick": 0, "entities": {}, "systems": {}})
	
	# 2. Spawn units in a grid
	var side = ceil(sqrt(count))
	var unit_def = load("res://data/units/soldier.tres")
	for i in range(count):
		var x = (i % int(side)) * 2
		var z = floor(i / side) * 2
		EntityFactory.spawn_unit(unit_def, Vector3(x, 0, z), 0)

func _simulation_tick() -> void:
	if not benchmark_running: return
	
	# After 10 seconds, record average step time
	# Simplified: just tracking last few ticks
	pass

func _print_results() -> void:
	print("--- BENCHMARK RESULTS ---")
	for res in results:
		print("Units: %d | Avg Step: %.2fms | Mem: %.2f MB" % [res.count, res.avg_step, res.mem])
