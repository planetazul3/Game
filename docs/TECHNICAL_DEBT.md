# Technical Debt & Future Milestones (STABILIZED)

## Resolved Debt (Milestone 1-18)

1.  [x] **EventBus Fallback Routing**: All systems now use pure `CommandBuffer` and `EventBus` communication.
2.  [x] **Faction Assumptions**: Replaced with a dynamic `FactionRegistry`.
3.  [x] **Visibility Shading**: Implemented shader-based Fog of War with explored/unexplored states.
4.  [x] **Collision Avoidance**: Implemented deterministic circle-collision resolution in `TransformIntegrator`.
5.  [x] **Node Grouping Reliance**: Replaced legacy group queries with O(1) `ComponentRegistry` lookups.
6.  [x] **Serialization Integration**: Every system and component now implements `save_state()` and `load_state()`.
7.  [x] **Scalability Limits**: Implemented `JobSystem` and `FlowField` navigation, enabling stable 1000+ unit simulations.

## New Future Milestones

1.  **Production Content**: Populating `data/` with high-fidelity units, buildings, and tech.
2.  **Network Performance**: Fine-tuning the `NetworkManager` for high-latency P2P environments.
3.  **UI Refinement**: Building a production-grade HUD utilizing the `TacticalInfluenceSystem`.
4.  **Audio Design**: Implementing a spatialized, data-driven audio pipeline.
