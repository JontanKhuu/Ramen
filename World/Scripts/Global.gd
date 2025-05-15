extends Node

enum RESOURCES_TRACKED{
	NONE, WOOD , BERRIES , COINS ,HOMES ,STONE, VENISON, CLOTHES, HIDES, 
	STEAK, IRONORE, IRON, TOOLS
}
var foods : Array = ["FLYTRAP BERRIES","STEAK"]

enum BUILDINGS{
	# plop
	NONE = 0, HOUSE = 1, STORAGE = 2,
	HUNT = 3, TANNERY, MINE, COOKERY, SMELTER,
	FORGE = 8, FISHHUT, FORESTER,
	# drawing area to place
	FARM = 11, HARVEST , ROAD , 
}
enum WORKPLACE {
	NONE = 0, HUNT, CLOTH, MINE, COOKERY, FISH, SMELTER, FORGE
}
enum JOB{
	NONE = 0, LABORER= 1, BUILDER = 2, FARMER = 3,HUNTER = 4, TANNER, 
	MINER, COOK, CHILD, SMELTER, BLACKSMITH
}
enum VILLAGER_STATE{
	WORKING, RESTING, SLEEPING
}

var build_queue = []
var drop_queue = []
var tribute_payment : float
var job_queues : Dictionary = {
	JOB.LABORER : []
}

var value_dict : Dictionary = {
	RESOURCES_TRACKED.WOOD : 1,
	RESOURCES_TRACKED.BERRIES : 2,
	RESOURCES_TRACKED.STONE : 1,
	RESOURCES_TRACKED.VENISON : 2,
	RESOURCES_TRACKED.CLOTHES : 4,
	RESOURCES_TRACKED.HIDES : 2,
	RESOURCES_TRACKED.STEAK : 3,
	RESOURCES_TRACKED.IRONORE : 2,
	RESOURCES_TRACKED.IRON : 3,
	RESOURCES_TRACKED.TOOLS : 5,
	
}
var inventory_dict : Dictionary # for overall storage
var building_inventory_dict : Dictionary = { # for individual storages
	RESOURCES_TRACKED.NONE : 0,
	RESOURCES_TRACKED.WOOD : 0,
	RESOURCES_TRACKED.BERRIES : 0,
	RESOURCES_TRACKED.COINS : 0,
	RESOURCES_TRACKED.HOMES : 0,
	RESOURCES_TRACKED.STONE : 0,
	RESOURCES_TRACKED.VENISON : 0,
	RESOURCES_TRACKED.HIDES : 0,
	RESOURCES_TRACKED.CLOTHES : 0,
	RESOURCES_TRACKED.STEAK : 0,
	RESOURCES_TRACKED.IRONORE : 0,
	RESOURCES_TRACKED.IRON : 0,
	RESOURCES_TRACKED.TOOLS : 0,
}
var naming_dict : Dictionary = {
	RESOURCES_TRACKED.WOOD : "WOOD",
	RESOURCES_TRACKED.BERRIES : "FLYTRAP BERRIES",
	RESOURCES_TRACKED.COINS : "COINS",
	RESOURCES_TRACKED.HOMES : "HOMES",
	RESOURCES_TRACKED.STONE : "STONE",
	RESOURCES_TRACKED.HIDES : "HIDES",
	RESOURCES_TRACKED.VENISON : "VENISON",
	RESOURCES_TRACKED.CLOTHES : "CLOTHES",
	RESOURCES_TRACKED.STEAK : "STEAK",
}
var job_name_dict : Dictionary = {
	JOB.NONE : "NONE",
	JOB.LABORER : "LABORER",
	JOB.BUILDER : "BUILDER",
	JOB.FARMER : "FARMER",
	JOB.HUNTER : "HUNTER",
	JOB.TANNER : "TANNER",
	JOB.MINER : "MINER",
	JOB.COOK : "COOK",
	JOB.SMELTER : "SMELTER",
	JOB.BLACKSMITH : "BLACKSMITH",
}
var job_limit_dict : Dictionary = {
	JOB.FARMER : 0,
	JOB.HUNTER : 0,
	JOB.TANNER : 0,
	JOB.MINER : 0,
	JOB.COOK : 0,
	JOB.SMELTER : 0,
	JOB.BLACKSMITH : 0,
}

func update_storages() -> void:
	inventory_dict = building_inventory_dict.duplicate()
	# the only groups with storages are tent, workplace, and storage
	var storages = get_tree().get_nodes_in_group("STORAGE")
	storages.append_array(get_tree().get_nodes_in_group("WORKPLACE"))
	storages.append_array(get_tree().get_nodes_in_group("TENT"))
	for storage in storages:
		for key in inventory_dict:
			inventory_dict[key] += storage.storage[key]

func set_villagers_state(state : VILLAGER_STATE) -> void:
	for villager : Villager in get_tree().get_nodes_in_group("VILLAGER"):
		villager.state = state
		if state == Global.VILLAGER_STATE.RESTING:
			villager.task = villager.LOOKING_FOR.EAT
			villager._target = null

func update_job_limits() -> void:
	for key in job_limit_dict:
		job_limit_dict[key] = 0
	for workplace in get_tree().get_nodes_in_group("WORKPLACE"):
		match workplace.type:
			WORKPLACE.HUNT:
				job_limit_dict[JOB.HUNTER] += 2
			WORKPLACE.CLOTH:
				job_limit_dict[JOB.TANNER] += 2
			WORKPLACE.MINE:
				job_limit_dict[JOB.MINER] += 2
			WORKPLACE.COOKERY:
				job_limit_dict[JOB.COOK] += 2
			WORKPLACE.SMELTER:
				job_limit_dict[JOB.SMELTER] += 2
			WORKPLACE.FORGE:
				job_limit_dict[JOB.BLACKSMITH] += 2
	# farm
	var farm_tiles = get_tree().get_nodes_in_group("CROP").size()
	job_limit_dict[JOB.FARMER] =  1000 #int(farm_tiles / 8)
	
