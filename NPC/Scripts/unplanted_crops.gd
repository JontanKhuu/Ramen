@tool
extends UtilityAiConsideration

func score() -> float:
	var crops = get_tree().get_nodes_in_group("CROP")
	for crop in crops:
		if !crop.planted:
			return 1.0
	return 0.0
