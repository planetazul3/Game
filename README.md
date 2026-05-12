# Game

Real-time strategy and exploration game for Linux PC built with Godot 4.

## Concept

A hybrid RTS/exploration experience featuring two initial factions:

- Solaris Dominion
- Umbral Collective

Players expand territory, harvest energy, explore procedural regions, and command units in real time.

## Planned Features

- Real-time strategy combat
- Fog of war
- Procedural exploration sectors
- Dynamic resource economy
- AI-controlled factions
- Single-player skirmish mode
- Linux-first development
- Modular architecture for future multiplayer support

## Engine

- Godot 4.4 (use `godot4.4` to execute)

## Project Structure

```text
assets/
  textures/
  audio/sfx/
  audio/music/
  fonts/
  shaders/
scripts/
scenes/
data/
```

## Linux Export

To export the game for Linux from the command line, run:
```bash
godot4.4 --headless --export-release "Linux/X11"
```

## Initial Factions

### Solaris Dominion
High-tech energy civilization focused on shields, drones, and precision warfare.

### Umbral Collective
Adaptive biomechanical faction specialized in stealth, regeneration, and map control.

## Roadmap

- Core RTS systems
- Unit selection and commands
- Resource harvesting
- Procedural world sectors
- Combat AI
- Save system
- Steam/Linux packaging
