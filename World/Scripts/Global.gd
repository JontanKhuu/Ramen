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

@export var wood := 5
@export var coins := 0

var build_queue = []
