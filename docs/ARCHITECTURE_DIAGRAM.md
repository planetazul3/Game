# Architecture Diagram

The project follows a direct, scene-based Godot architecture.

## Core Components
- **PlayerController**: Handles input, selection, and orders.
- **Unit**: Individual agent with movement (NavigationAgent3D) and combat logic.
- **UnitRegistry**: Static registry for efficient unit lookups.
- **RTSCamera**: WASD and zoom controls.

## Flow
1. Input → PlayerController
2. PlayerController → Raycast → Command
3. Command → Unit(s)
4. Unit → Movement/Combat
