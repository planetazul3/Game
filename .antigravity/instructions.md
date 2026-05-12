# Agentic Development Instructions - Godot 4 Game

You are working on a Godot 4 project structured with a component-based architecture and decoupled systems.

## Core Principles
1. **Decoupling**: Never allow systems (e.g., `CombatSystem`, `MovementSystem`) to reference each other directly. Use `scripts/core/event_bus.gd` to communicate via signals.
2. **Type Safety**: Use static typing for all variables, constants, and function parameters/return types.
3. **3D Consistency**: The game is 3D. Always use `Vector3` for spatial coordinates unless specifically working on 2D UI.
4. **Verification**: After modifying scripts, verify them using `godot --headless --path . --check-only` or `gdlint`.

## Agentic Behavior & Professional Standards
1. **Atomic Commits**: Every logical change must be committed separately with a clear, descriptive message following Conventional Commits.
2. **Synchronized State**: Always `git push` after a successful commit to ensure the remote repository reflects the latest progress.
3. **CI/CD Vigilance**: Before finishing a task, check the status of the CI pipeline. If a change breaks the build or linting, it is your responsibility to fix it immediately.
4. **Professionalism & Quality**: Maintain a high standard of professional communication and code quality. Avoid placeholders, "TODOs" without tracking, or incomplete implementations.
5. **Anti-Laziness Policy**: Never cut corners. Provide complete, verified solutions. Do not ask the user to "fill in the blanks" for core logic. Research thoroughly before making architectural decisions.
6. **MemPalace Integration**: Consistently update the Palace with key decisions to maintain long-term project intelligence.

## Project Structure
- `scripts/core/`: Autoloads and global managers (EventBus).
- `scripts/systems/`: High-level logic systems that process components.
- `scripts/components/`: Data containers (`RefCounted`) attached to entities.
- `scenes/`: Godot scenes and prefabs.

## MemPalace
- All architectural decisions and session history should be stored in `wing_godot_game`.
- Use the knowledge graph to track entity relationships.

## Git Workflow
- Perform atomic commits for every logical step.
- Follow conventional commit messages (`feat:`, `fix:`, `refactor:`, etc.).
