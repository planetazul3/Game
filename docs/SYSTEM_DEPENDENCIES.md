# System Dependencies

Strict decoupling is enforced through the Event Bus and Simulation Manager. No system holds direct references to other systems.

## Event Flow & Dependencies

1. **InputManager**
   - **Emits:** `unit_selected`, `selection_cleared`, `selection_box_finished`, `command_issued`
   - **Depends On:** Native Input system, raycasting.

2. **SelectionSystem**
   - **Listens:** `unit_selected`, `selection_cleared`, `selection_box_finished`, `unit_died`
   - **Depends On:** `SelectableComponent` data.

3. **CommandSystem**
   - **Listens:** `command_issued`
   - **Depends On:** Routes intended targets to `MovementComponent`, `CombatComponent`, and `GathererComponent`.

4. **MovementSystem**
   - **Ticks:** Processes throttled pathfinding and velocity integration.
   - **Depends On:** `MovementComponent`, `NavigationAgent3D` properties.

5. **CombatSystem**
   - **Ticks:** Checks distances and cooldowns.
   - **Emits:** `combat_started`, `unit_died`
   - **Depends On:** `CombatComponent`, `HealthComponent`.
   - **Fallback Routing:** Directly enqueues units into `MovementSystem.entities_to_move` if target is out of range. *(Tech Debt: Should route via EventBus in future).*

6. **ResourceSystem**
   - **Ticks:** Checks gather timers and distances.
   - **Emits:** `resource_collected`
   - **Depends On:** `GathererComponent`, resource nodes implementing `extract()`.

7. **AISystem**
   - **Ticks:** Evaluates FSM.
   - **Emits:** `command_issued`
   - **Depends On:** `CombatComponent` for state checks.

8. **VisibilitySystem**
   - **Ticks:** Manages spatial partitioning grid and FOV checks.
   - **Emits:** `visibility_changed`
   - **Depends On:** `VisibilityComponent`.

## AutoLoad Dependencies

- All logic systems heavily rely on **EventBus** for inter-system communication.
- Entity destruction explicitly depends on **EntityManager**.
- Any procedural behavior requires **DeterministicRandom**.
