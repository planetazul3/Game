## Description
Please include a summary of the change and which issue is fixed. Please also include relevant motivation and context.

Fixes # (issue)

## Architectural Checklist Verification
Please review and check off the following architectural constraints to ensure adherence to our project guidelines:
- [ ] Code adheres to ECS-like architecture where components are pure data containers and logic resides in centralized systems.
- [ ] Gameplay logic does not rely on Godot's `_process()` frame-dependent updates; it uses the custom fixed-tick `SimulationManager`.
- [ ] Core input map actions (e.g. `unit_select`, `unit_command`) are used appropriately.
- [ ] The system maintains a deterministic RTS environment (e.g., uses fixed-tick simulation and seeded PRNG).
- [ ] Decoupled communication is achieved via the `EventBus`.
- [ ] Centralized entity lifecycle management is handled via the `EntityManager`.
- [ ] Any UI rendering mask modifications are explicitly scoped per the `CanvasItem` and `SubViewport` visibility masking architecture.
- [ ] Scripts are placed in the appropriate directory structure under `scripts/`.

## Type of change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] This change requires a documentation update

## How Has This Been Tested?
Please describe the tests that you ran to verify your changes. Provide instructions so we can reproduce.

- [ ] Test A
- [ ] Test B

## Checklist:
- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
