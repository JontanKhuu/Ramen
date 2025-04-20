extends Node

enum RESOURCES_TRACKED{
	WOOD = 0, FOOD = 1, COINS = 2,
}

enum BUILDINGS{
	NONE = 0, HOUSE = 1, STORAGE = 2, FARM = 3
}

enum JOB{
	NONE = 0, LABORER= 1, BUILDER = 2, FARMER = 3,
}
enum VILLAGER_STATE{
	WORKING, RESTING, SLEEPING
}

var build_queue = []

func set_villagers_state(state : VILLAGER_STATE):
	for villager in get_tree().get_nodes_in_group("VILLAGER"):
		villager.state = state
var value_dict : Dictionary = {
	RESOURCES_TRACKED.WOOD : 1,
	RESOURCES_TRACKED.FOOD : 2
}
var inventory_dict : Dictionary = {
	RESOURCES_TRACKED.WOOD : 10,
	RESOURCES_TRACKED.FOOD : 0,
	RESOURCES_TRACKED.COINS : 0
}
var naming_dict : Dictionary = {
	RESOURCES_TRACKED.WOOD : "WOOD",
	RESOURCES_TRACKED.FOOD : "FOOD",
	RESOURCES_TRACKED.COINS : "COINS"
}
