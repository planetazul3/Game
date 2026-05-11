# Software Architecture

## Engine

- Godot 4.x
- GDScript primary scripting layer
- Optional Python/Rust integration for advanced AI systems

## Core Design Principles

- Modular systems
- Data-driven faction design
- Linux-first compatibility
- Deterministic simulation where possible
- Future multiplayer readiness

## High-Level Modules

### Gameplay Layer

- Unit controller
- Combat system
- Economy system
- Exploration system
- Fog of war

### AI Layer

- Tactical AI
- Strategic AI
- Behavior trees
- Reinforcement-learning experimentation layer

### World Layer

- Procedural map generation
- Terrain sectors
- Environmental events

### Presentation Layer

- UI/HUD
- Audio manager
- Visual effects
- Animation system

## Data Architecture

JSON-driven faction and gameplay configuration.

## Future Networking Considerations

- Lockstep RTS synchronization
- Snapshot validation
- Deterministic command simulation

## Performance Goals

- Linux native support
- Steam Deck compatibility
- Stable 60 FPS minimum target
