extends Node


enum RESOURCES_TRACKED{
	WOOD, FOOD,
}

enum BUILDINGS{
	NONE = 0, HOUSE = 1, STORAGE = 2
}

enum JOB{
	NONE = 0, LABORER= 1, BUILDER = 2,
}

const WOOD = 0
const FOOD = 1

@export var wood := 5

var build_queue = []
