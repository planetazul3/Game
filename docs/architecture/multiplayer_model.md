# Multiplayer Model Architecture

## Overview
This document defines the architectural constraints and design philosophy for handling multiplayer in our Real-Time Strategy (RTS) game.

## Core Constraint: Lockstep vs. State-Sync
Due to the sheer number of entities typically present in an RTS environment and the requirement for precise, deterministic simulation, this project enforces a **Lockstep** networking architecture over a State-Sync architecture.

### Why Lockstep?
- **Bandwidth Efficiency:** In a lockstep model, only player inputs (commands) are sent over the network, rather than the state of thousands of individual units.
- **Determinism Requirement:** Every client must simulate the exact same game state given the same inputs and initial state. This demands strict determinism across all simulation logic.
- **Fairness & Consistency:** A fixed-tick simulation ensures that gameplay logic executes uniformly, independent of varied client framerates.

### Architectural Rules
1. **No Frame-Dependent Logic:** Game logic must never rely on Godot's `_process()` function. All gameplay logic must be executed within the custom, fixed-tick `SimulationManager`.
2. **Deterministic Inputs:** Actions, random number generation, and navigation must be strictly deterministic. We utilize a seeded PRNG (`DeterministicRandom`) to ensure cross-client consistency.
3. **Decoupled Simulation & Presentation:** The visual representation (rendering/animation) must be completely decoupled from the underlying logic. The `SimulationManager` ticks at a fixed rate, while presentation interpolation handles smooth rendering.

## Future Implementations
Any future features or systems must be reviewed against this lockstep model to ensure they do not introduce non-deterministic behavior or rely on state synchronization that would break the bandwidth and consistency constraints.
