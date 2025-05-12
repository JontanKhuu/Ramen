extends StaticBody2D
class_name Storage

@export var storage : Dictionary
@export var max_storage : int

func _ready() -> void:
	storage = Global.building_inventory_dict.duplicate(false)

func has_food() -> Array:
	var availFood : Array = []
	for food in Global.foods:
		if storage[Global.naming_dict.find_key(food)] > 0:
			availFood.append(Global.naming_dict.find_key(food))
	return availFood
