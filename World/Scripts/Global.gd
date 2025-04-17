extends Node

enum RESOURCES_TRACKED{
	WOOD = 0, FOOD = 1,
}

enum BUILDINGS{
	NONE = 0, HOUSE = 1, STORAGE = 2
}

enum JOB{
	NONE = 0, LABORER= 1, BUILDER = 2,
}
enum VILLAGER_STATE{
	WORKING, RESTING, SLEEPING
}

@export var wood := 5
@export var coins := 0

var build_queue = []

func set_villagers_state(state : VILLAGER_STATE):
	print("Ok")
	for villager in get_tree().get_nodes_in_group("VILLAGER"):
		villager.state = state
