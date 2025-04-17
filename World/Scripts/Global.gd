extends Node


enum RESOURCES_TRACKED{
	WOOD = 0, FOOD = 1, COINS = 2
}

enum BUILDINGS{
	NONE = 0, HOUSE = 1, STORAGE = 2
}

enum JOB{
	NONE = 0, LABORER= 1, BUILDER = 2, FARMER = 3,
}

var build_queue = []

var value_dict : Dictionary = {
	RESOURCES_TRACKED.WOOD : 1,
	RESOURCES_TRACKED.FOOD : 2
}
var inventory_dict : Dictionary = {
	RESOURCES_TRACKED.WOOD : 5,
	RESOURCES_TRACKED.FOOD : 0,
	RESOURCES_TRACKED.COINS : 0
}
