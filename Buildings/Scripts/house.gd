extends StaticBody2D
class_name House

const STORK = preload("res://NPC/Scenes/stork.tscn")

@export var slot1 : CharacterBody2D
@export var slot2 : CharacterBody2D
@export var deliveryPoint : Vector2i

@onready var tiles : Node2D = get_node("/root/World/TileMap")
@onready var NPCs : Node = get_node("/root/World/NPCs")
@onready var grassTiles : TileMapLayer = tiles.grass
@onready var villager = get_tree().get_nodes_in_group("VILLAGER")

var bed: Node2D
var south

func _ready() -> void:
	south = $south
	deliveryPoint = grassTiles.local_to_map(south.global_position)
	deliveryPoint += Vector2i(-4,0)
	bed = %bed
	assign_homes()
	
func birth() -> void:
	var stork = STORK.instantiate()
	stork.global_position = grassTiles.map_to_local(Vector2i(deliveryPoint.x,0))
	stork.deliveryPoint = grassTiles.map_to_local(deliveryPoint)
	stork.target = grassTiles.map_to_local(Vector2i(deliveryPoint.x,1000))
	NPCs.add_child(stork)
	pass

func has_space() -> bool:
	if slot1 == null or slot2 == null:
		return true
	return false

# will probably call assign homes again every at end of every rest period
func assign_homes() -> void:
	for unit in villager:
		if slot1 && slot2:
			break
		if unit.bed != null:
			continue
			
		if slot1 == null:
			slot1 = unit
			unit.bed = bed
		elif slot2 == null:
			slot2 = unit
			unit.bed = bed
