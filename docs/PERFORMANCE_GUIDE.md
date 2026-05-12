# RTS Performance & Scalability Guide

## Overview
This engine is designed to handle 1000+ units in real-time through aggressive optimization and parallelization.

## Optimization Layers
1.  **Job System**: Parallelizes expensive O(N) or O(N^2) tasks like visibility distance checks and spatial grid updates using Godot's `WorkerThreadPool`.
2.  **Spatial Partitioning**: The `SpatialGrid` reduces neighbor lookups from O(N^2) to O(1) for local interactions.
3.  **Flow Field Navigation**: Replaces per-unit A* pathfinding with a single vector field lookup per group, allowing hundreds of units to move with minimal CPU overhead.
4.  **Throttled AI/Influence**: Strategic reasoning and influence maps update at a lower frequency (1Hz) compared to the core simulation (30Hz).

## Scalability Targets
- **100 Units**: <1ms tick duration.
- **500 Units**: <5ms tick duration.
- **1000 Units**: <15ms tick duration (30Hz overhead limit: 33ms).

## Memory Management
- **Pre-allocation**: Large arrays and buffers are pre-allocated during initialization to avoid GC spikes.
- **PackedArrays**: Used for large data-heavy grids (influence maps, flow fields) to optimize memory density.
