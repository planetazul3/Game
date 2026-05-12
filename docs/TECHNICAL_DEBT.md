# Technical Debt & Future Milestones

## Known Technical Debt

1. **EventBus Fallback Routing:** Some systems (like CombatSystem) directly reference and append to the `MovementSystem.entities_to_move` array when attempting to close gaps for attacking. This bypasses the pure EventBus paradigm and creates a soft circular dependency in logic.
2. **Hardcoded Faction Assumptions:** The vertical slice currently assumes `faction_id == 0` is the player in systems like the `VisibilitySystem` and `ResourceVictory`.
3. **Visibility System Shading:** The logical FoW tracking (states) is complete, but there is no shader implementation to visually hide or grey out the environment meshes for unexplored/explored territory yet.
4. **Collision Avoidance:** The current congestion recovery uses a primitive velocity lerp against intended direction. Heavy clustering (200+ units) can still result in slight jittering when fighting Godot's native physics resolution.
5. **Node Grouping Reliance:** We heavily rely on `get_tree().get_nodes_in_group("selectable")` to iterate over all active game entities. A robust ECS would have dedicated caches per component type.
6. **Serialization Integration:** While `entity_id` is assigned at spawn via the `EntityManager`, systems do not yet have standardized `save_state()` / `load_state()` methods for full snapshot serialization.

## Current Scalability Limits

- **Unit Count:** Testing verified stable ticks up to ~250 units in mixed scenarios. Beyond 300, the `MovementSystem` path recalculation and `VisibilitySystem` nested loops begin to cause physics frame drops.
- **Pathfinding:** Relies on native `NavigationAgent3D`, which forces threaded updates that we cannot fully tightly pack into the deterministic frame if thousands of units requested paths simultaneously.

## Next Recommended Milestone

**Architectural Stabilization Complete. Proceed to Milestone 2: Game Loop Expansion**

1. Procedural sector generation.
2. Faction asymmetry expansion (tech trees, distinct visual unit archetypes).
3. Advanced combat abilities (AoE, status effects).
4. Audio pipeline integration (spatial audio, event-driven sound effects).
5. Visual FoW shader integration.
