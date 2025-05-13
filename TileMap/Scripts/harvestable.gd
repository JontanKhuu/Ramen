extends StaticBody2D
class_name Harvestable

const TREESPRITE = preload("res://TileMap/Assets/TreeSprite.png")
const ORE = preload("res://TileMap/Assets/IronOre.png")
const STONE = preload("res://TileMap/Assets/Stone.png")

enum TYPE{
	NONE, TREE, STONE, ORE
}

@export var type : TYPE
@export var reward : Global.RESOURCES_TRACKED
@export var amount : int
@export var marked : bool
@export var tile : Vector2i

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	_handle_type()
	
func _handle_type() -> void:
	match type:
		1: # tree
			sprite.texture = TREESPRITE
			sprite.hframes = 4
			sprite.frame = 3
			sprite.offset = Vector2(-1,-27)
			reward = Global.RESOURCES_TRACKED.WOOD
			amount = 3
		2: # STONE
			sprite.texture = STONE
			sprite.hframes = 1
			sprite.offset = Vector2(0,-10)
			reward = Global.RESOURCES_TRACKED.STONE
			amount = 2
		3: # ORE 
			sprite.texture = ORE
			sprite.hframes = 1
			reward = Global.RESOURCES_TRACKED.IRONORE
			amount = 2
