extends StaticBody2D

const HOUSE = preload("res://Buildings/Scenes/house.tscn")
const STORAGE = preload("res://Buildings/Scenes/storage.tscn")
const WORKPLACE = preload("res://Buildings/Scenes/work_building.tscn")

@export var building : Global.BUILDINGS
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
	villagers = villagers.filter(func(element):return element.job == Global.JOB.BUILDER)
	if villagers.size() > 0:
		builder = villagers[0]
		_handle_building_time(delta,building)
	
func _handle_building_time(delta : float, building_type):
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
	var place
	if building >= 3:
		place = WORKPLACE.instantiate()
	match building: # type of building
		1: # House
			place = HOUSE.instantiate()
		2: # Storage
			place = STORAGE.instantiate()
		3: # Hunt Camp
			place.type = Global.WORKPLACE.HUNT
		4:
			place.type = Global.WORKPLACE.CLOTH
		5:
			place.type = Global.WORKPLACE.MINE
		6:
			place.type = Global.WORKPLACE.COOKERY
		7:
			place.type = Global.WORKPLACE.SMELTER
		8:
			place.type = Global.WORKPLACE.FORGE
	place.global_position = global_position
	get_parent().add_child(place)
	Global.update_job_limits()
	get_tree().get_first_node_in_group("JOBMANAGER")._update_spinbox_max_values()
	
	if builder:
		builder._target = null
	queue_free()

func remove_nav_under() -> void:
	for x in range(west.global_position.x,east.global_position.x):
		for y in range(north.global_position.y,south.global_position.y):
			var pos = grassTiles.local_to_map(Vector2(x,y))
			grassTiles.set_cell(pos,0,Vector2i(0,1),1)
	pass
