extends Node

enum RESOURCES_TRACKED{
	NONE, WOOD , FOOD , COINS ,HOMES ,STONE, VENISON, LEATHER, HIDES
}

enum BUILDINGS{
	# plop
	NONE = 0, HOUSE = 1, STORAGE = 2,
	HUNT = 3, TANNERY,
	# drawing area to place
	FARM , HARVEST , ROAD , 
}
enum WORKPLACE {
	NONE = 0, HUNT, CLOTH
}
enum JOB{
	NONE = 0, LABORER= 1, BUILDER = 2, FARMER = 3,HUNTER = 4, TANNER
}
enum VILLAGER_STATE{
	WORKING, RESTING, SLEEPING
}

var build_queue = []
var tribute_payment : float

var value_dict : Dictionary = {
	RESOURCES_TRACKED.WOOD : 1,
	RESOURCES_TRACKED.FOOD : 2,
	RESOURCES_TRACKED.STONE : 2,
	RESOURCES_TRACKED.VENISON : 2,
	RESOURCES_TRACKED.HIDES : 2,
	RESOURCES_TRACKED.LEATHER : 4,
}
var inventory_dict : Dictionary = {
	RESOURCES_TRACKED.NONE : 0,
	RESOURCES_TRACKED.WOOD : 10,
	RESOURCES_TRACKED.FOOD : 0,
	RESOURCES_TRACKED.COINS : 0,
	RESOURCES_TRACKED.HOMES : 0,
	RESOURCES_TRACKED.STONE : 0,
	RESOURCES_TRACKED.VENISON : 0,
	RESOURCES_TRACKED.HIDES : 0,
	RESOURCES_TRACKED.LEATHER : 0,
}
var naming_dict : Dictionary = {
	RESOURCES_TRACKED.WOOD : "WOOD",
	RESOURCES_TRACKED.FOOD : "FOOD",
	RESOURCES_TRACKED.COINS : "COINS",
	RESOURCES_TRACKED.HOMES : "HOMES",
	RESOURCES_TRACKED.STONE : "STONE",
	RESOURCES_TRACKED.HIDES : "HIDES",
	RESOURCES_TRACKED.VENISON : "VENISON",
	RESOURCES_TRACKED.LEATHER : "LEATHER",
}
var job_name_dict : Dictionary = {
	JOB.NONE : "NONE",
	JOB.LABORER : "LABORER",
	JOB.BUILDER : "BUILDER",
	JOB.FARMER : "FARMER",
	JOB.HUNTER : "HUNTER",
	JOB.TANNER : "TANNER"
}
var job_limit_dict : Dictionary = {
	JOB.FARMER : 0,
	JOB.HUNTER : 0,
	JOB.TANNER : 0.
}

func set_villagers_state(state : VILLAGER_STATE) -> void:
	for villager in get_tree().get_nodes_in_group("VILLAGER"):
		villager.state = state

func update_job_limits() -> void:
	for key in job_limit_dict:
		job_limit_dict[key] = 0
	for workplace in get_tree().get_nodes_in_group("WORKPLACE"):
		match workplace.type:
			WORKPLACE.HUNT:
				job_limit_dict[JOB.HUNTER] += 2
			WORKPLACE.CLOTH:
				job_limit_dict[JOB.TANNER] += 2
	# farm
	var farm_tiles = get_tree().get_nodes_in_group("CROP").size()
	job_limit_dict[JOB.FARMER] = int(farm_tiles / 8)
	
