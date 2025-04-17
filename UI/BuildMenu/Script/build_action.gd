extends Control

@export var xDimension : int
@export var yDimension : int
@export var woodCost : int
@export var stoneCost : int
@export var building : Buildings.BUILDINGS
@export var icon : CompressedTexture2D

@onready var tileMap : BuildMap = get_node("/root/World/TileMap")

func _ready() -> void:
	$Button.icon = icon

func _on_button_pressed() -> void:
	tileMap.set_build_settings(xDimension, yDimension,woodCost, building)
