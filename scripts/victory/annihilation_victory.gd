extends VictoryCondition
class_name AnnihilationVictory

func evaluate(simulation_manager) -> bool:
    return simulation_manager.active_factions.size() <= 1
