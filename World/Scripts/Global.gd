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
var value_dict : Dictionary = {
	RESOURCES_TRACKED.WOOD : 1,
	RESOURCES_TRACKED.FOOD : 2
}
var inventory_dict : Dictionary = {
	RESOURCES_TRACKED.WOOD : 5,
	RESOURCES_TRACKED.FOOD : 0,
	RESOURCES_TRACKED.COINS : 0
}
