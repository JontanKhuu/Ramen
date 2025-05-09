extends House
class_name Tent

@export var storage : Dictionary
@export var max_storage : int
@onready var entrance: Node2D = $Entrance

func _ready() -> void:
	south = $south
	deliveryPoint = grassTiles.local_to_map(south.global_position)
	deliveryPoint += Vector2i(-4,0)
	
	storage = Global.building_inventory_dict.duplicate(false)
	storage[Global.RESOURCES_TRACKED.WOOD] = 10
	storage[Global.RESOURCES_TRACKED.BERRIES] = 0
	storage[Global.RESOURCES_TRACKED.HIDES] = 2
	
	bed = entrance
	assign_homes()
	Global.update_storages()

func has_food() -> Array:
	var availFood : Array = []
	for food in Global.foods:
		if storage[Global.naming_dict.find_key(food)] > 0:
			availFood.append(Global.naming_dict.find_key(food))
	return availFood
