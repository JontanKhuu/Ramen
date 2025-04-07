extends Control

enum BUILDINGS{
	HOUSE = 0,
}

@export var xDimension : int
@export var yDimension : int
@export var woodCost : int
@export var stoneCost : int
@export var building : BUILDINGS

@onready var tileMap : BuildMap = get_node("/root/World/TileMap")

func _on_button_pressed() -> void:
	print("wow")
	#tileMap.set_build_settings(xDimension, yDimension)
