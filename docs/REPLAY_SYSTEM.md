# RTS Replay System Documentation

## Overview
Replays in this engine are stored as a sequence of deterministic commands anchored to a starting seed.

## Structure
A replay file contains:
1.  **World Seed**: The integer used for procedural generation.
2.  **Command Timeline**: A dictionary mapping `tick_number` to an array of commands.
3.  **Metadata**: Map name, players, and match duration.

## Recording Process
1.  **Command Interception**: The `EventBus` captures all commands issued via the UI or AI.
2.  **Serialization**: Commands are stored with their target tick to ensure they execute at the exact same moment during playback.

## Playback Process
1.  **Simulation Reset**: The engine reloads the map using the recorded seed.
2.  **Injecting Commands**: The `ReplayManager` feeds recorded commands into the `CommandBuffer` as the simulation progresses.
3.  **Validation**: Every tick is compared against recorded checksums to verify integrity.
