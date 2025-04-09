extends StaticBody2D

const HOUSE = preload("res://Buildings/Scenes/house.tscn")
const STORAGE = preload("res://Buildings/Scenes/storage.tscn")

@export var building : Buildings.BUILDINGS
@export var timeToBuild : float = 5.0


func _process(delta: float) -> void:
	_handle_building_time(delta,building)
	
	print(timeToBuild)
	
func _handle_building_time(delta : float, building):
	if timeToBuild <= 0.0:
		_build_chosen_building()
		return
	timeToBuild -= delta
	
	pass

func _build_chosen_building():
	match building: # type of building
		1: # House
			var house = HOUSE.instantiate()
			house.global_position = global_position
			get_parent().add_child(house)
		2: # Storage
			var storage = STORAGE.instantiate()
			storage.global_position = global_position
			get_parent().add_child(storage)
	queue_free()
