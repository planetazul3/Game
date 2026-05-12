# Tick Execution Order

The engine drives logic through the fixed `_physics_process` in `SimulationManager.gd`. The manager sequentially iterates over registered systems.

## Sequence Flow

1. **Godot Frame Start:** Native inputs populate internal engine queues.
2. **`InputManager._unhandled_input`:** Native events trigger EventBus actions (e.g., `selection_box_finished`, `command_issued`).
3. **Simulation Tick Start (`SimulationManager._physics_process`):**
    *   **Tick Increment:** `current_tick` counter increments.
    *   **System Tick Execution (in order of scene tree registration):**
        1.  `InputManager`: Currently pass-through.
        2.  `SelectionSystem`: Processes buffered selections.
        3.  `CommandSystem`: Processes buffered commands, assigning data to Components.
        4.  `MovementSystem`: Evaluates pathfinding throttles, adjusts velocities, manages avoidance.
        5.  `CombatSystem`: Iterates over combatants, processes ranges, applies damage, triggers `unit_died`.
        6.  `ResourceSystem`: Iterates over gatherers, extracts resources, updates totals.
        7.  `AISystem`: Evaluates AI FSM, triggers new commands on EventBus if state changes.
        8.  `VisibilitySystem`: Runs grid partitioning pass, evaluates FOV radiuses, emits visibility toggles.
    *   **Victory Evaluation:** Evaluated on interval (e.g., every 60 ticks) across all registered `VictoryCondition` objects.
4. **Native Rendering/Physics:** Godot applies `CharacterBody3D.move_and_slide()` transforms to the visual layer.
