# Architecture Diagram

```mermaid
graph TD;
    subgraph Engine Layer
        Godot[Godot 4 Engine]
    end

    subgraph Core
        SimulationManager[Simulation Manager]
        EventBus[Event Bus (AutoLoad)]
        EntityManager[Entity Manager (AutoLoad)]
        DeterministicRandom[Seeded PRNG (AutoLoad)]
    end

    subgraph Systems (Ticked by SimulationManager)
        Input[Input Manager]
        SelectSys[Selection System]
        CmdSys[Command System]
        NavSys[Movement System]
        ComSys[Combat System]
        ResSys[Resource System]
        AISys[AI System (FSM)]
        VisSys[Visibility System]
    end

    subgraph Entities & Components (Data Containers)
        Unit[Unit Entity]
        ResNode[Resource Node Entity]

        Health[Health Component]
        Movement[Movement Component]
        Combat[Combat Component]
        Selectable[Selectable Component]
        Gatherer[Gatherer Component]
        Visibility[Visibility Component]
    end

    SimulationManager -->|ticks sequentially| Systems
    Systems -->|read/write data| Components
    Systems -->|emit/listen| EventBus
    Unit -->|contains| Components
    ResNode -->|contains| Components
    EventBus -->|triggers events| Systems
```
