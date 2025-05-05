extends House
class_name Tent

@export var storage : Dictionary
@export var max_storage : int
@onready var entrance: Node2D = $Entrance

func _ready() -> void:
	storage = Global.building_inventory_dict.duplicate(false)
	storage[Global.RESOURCES_TRACKED.WOOD] = 10
	storage[Global.RESOURCES_TRACKED.FOOD] = 2
	storage[Global.RESOURCES_TRACKED.HIDES] = 2
	
	bed = entrance
	assign_homes()
	Global.update_storages()
