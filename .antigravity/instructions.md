GAMEPLAY FIRST DIRECTIVE

This project is an EARLY RTS PROTOTYPE.

Primary goal:
Create a fun and responsive RTS.

DO NOT introduce:
- ECS
- EventBus
- lockstep networking
- replay systems
- SimulationManager
- command buffers
- generic architecture layers
- unnecessary abstractions

Prefer:
- direct node references
- simple gameplay scripts
- scene-local logic
- iteration speed
- readability
- playable features

The project should remain:
- small
- understandable
- easy to iterate
- fun to modify

If a system does not directly improve gameplay:
DO NOT BUILD IT.
