extends Node
# JobSystem: Handles deterministic parallel computation for the RTS engine

var _max_threads: int = OS.get_processor_count()
var _active_jobs: Array[int] = [] # Group IDs

var last_execution_ms: float = 0.0
var last_merge_ms: float = 0.0
var queue_depth: int = 0

func _ready() -> void:
	print("JobSystem: Initialized with ", _max_threads, " threads.")

func run_job_group(count: int, callable: Callable) -> int:
	# Godot 4 WorkerThreadPool for high performance
	var group_id = WorkerThreadPool.add_group_task(callable, count)
	_active_jobs.append(group_id)
	queue_depth += count
	return group_id

func wait_for_all() -> void:
	var start = Time.get_ticks_usec()
	
	for group_id in _active_jobs:
		WorkerThreadPool.wait_for_group_task_completion(group_id)
	
	_active_jobs.clear()
	queue_depth = 0
	last_execution_ms = (Time.get_ticks_usec() - start) / 1000.0

# Pattern for Deterministic Merge
# 1. Dispatch jobs (WorkerThreadPool)
# 2. Each job writes to a pre-allocated array slot [index]
# 3. wait_for_all()
# 4. Process the array in the main tick (Reduction)
