extends StaticBody3D
class_name ResourceNodeEntity

@export var resource_type: String = "energy"
@export var amount: int = 1000

func extract(extract_amount: int) -> int:
	var extracted = min(extract_amount, amount)
	amount -= extracted

	if amount <= 0:
		EntityManager.destroy_entity(self)

	return extracted
