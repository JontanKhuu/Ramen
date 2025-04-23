extends StaticBody2D

const HOUSE = preload("res://Buildings/Scenes/house.tscn")
const STORAGE = preload("res://Buildings/Scenes/storage.tscn")

@export var building : Buildings.BUILDINGS
@export var timeToBuild : float = 5.0

@onready var tiles : Node2D = get_node("/root/World/TileMap")
@onready var grassTiles : TileMapLayer = tiles.grass
@onready var treeTiles : TileMapLayer = tiles.tree
@onready var north: Node2D = %North
@onready var south: Node2D = %South
@onready var west: Node2D = %West
@onready var east: Node2D = %East
@onready var points: Node2D = %Points
@onready var area: Area2D = $Area2D

var builder : Villager 
var villagers 

func _ready() -> void:
	Global.build_queue.append(self)
	remove_nav_under()

func _process(delta: float) -> void:
	villagers = area.get_overlapping_bodies()
	if villagers.size() > 0:
		builder = villagers[0]
		_handle_building_time(delta,building)
	
func _handle_building_time(delta : float, building):
	if timeToBuild <= 0.0:
		Global.build_queue.remove_at(Global.build_queue.find(self))
		
		for villager in villagers:
			villager._target = null
			villager.find_building()
		
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

func remove_nav_under() -> void:
	for point : Node2D in points.get_children():
		var pos = grassTiles.local_to_map(point.global_position)
		grassTiles.set_cell(pos,0,Vector2i(0,1),1)
	pass
