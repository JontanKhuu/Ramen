extends Node

enum RESOURCES_TRACKED{
	WOOD = 0, FOOD = 1, COINS = 2,HOMES = 3
}

enum BUILDINGS{
	NONE = 0, HOUSE = 1, STORAGE = 2, FARM = 3, HARVEST = 4, ROAD = 5
}

enum JOB{
	NONE = 0, LABORER= 1, BUILDER = 2, FARMER = 3,
}
enum VILLAGER_STATE{
	WORKING, RESTING, SLEEPING
}

var build_queue = []
var tribute_payment : float

var value_dict : Dictionary = {
	RESOURCES_TRACKED.WOOD : 1,
	RESOURCES_TRACKED.FOOD : 2
}
var inventory_dict : Dictionary = {
	RESOURCES_TRACKED.WOOD : 10,
	RESOURCES_TRACKED.FOOD : 0,
	RESOURCES_TRACKED.COINS : 0,
	RESOURCES_TRACKED.HOMES : 0
}
var naming_dict : Dictionary = {
	RESOURCES_TRACKED.WOOD : "WOOD",
	RESOURCES_TRACKED.FOOD : "FOOD",
	RESOURCES_TRACKED.COINS : "COINS",
	RESOURCES_TRACKED.HOMES : "HOMES"
}


func set_villagers_state(state : VILLAGER_STATE) -> void:
	for villager in get_tree().get_nodes_in_group("VILLAGER"):
		villager.state = state
