extends StaticBody2D
class_name Storage

@export var storage : Dictionary
@export var max_storage : int

func _ready() -> void:
	storage = Global.building_inventory_dict.duplicate(false)
