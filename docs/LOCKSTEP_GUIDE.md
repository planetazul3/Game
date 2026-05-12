# RTS Lockstep Architecture Guide

## Overview
This engine utilizes a strict deterministic lockstep architecture to ensure perfect synchronization across all clients in a multiplayer match.

## Core Principles
1.  **Fixed-Tick Simulation**: The simulation runs at a constant 30Hz (`TICK_RATE`). All gameplay logic occurs within `tick(delta_fixed)` methods.
2.  **Command-Based Authority**: Units do not move themselves. The `CommandBuffer` collects inputs and distributes them to systems for execution on a specific future tick.
3.  **Deterministic Math**: All calculations (movement, combat, collision) use snapped coordinates and fixed-order iterations to prevent floating-point drift across platforms.
4.  **No Side-Effects**: Simulation logic must never depend on rendering state, frame rate, or platform-specific OS features.

## Checksum Validation
Every 30 ticks (1 second), the `SimulationManager` generates a SHA-256 checksum of the entire world state.
- **Desync Detection**: If checksums differ between clients, a desync is declared.
- **Provenance**: Checksums include entity positions, health, and current simulation tick.
