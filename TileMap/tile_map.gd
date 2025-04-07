extends Node2D
class_name BuildMap

const HOUSE = preload("res://Buildings/house.tscn")

@onready var grass: TileMapLayer = $Grass
@onready var tree: TileMapLayer = $Tree
@onready var hover: TileMapLayer = $Hover

var is_building : bool = true

var xdim : int = 2
var ydim : int = 2

func _process(delta: float) -> void:
	if is_building:
		_handle_hover()
	pass

func set_build_settings(xd : int, yd : int):
	xdim = xd
	ydim = yd
	is_building = true

func _handle_hover() -> void:
	for cell in hover.get_used_cells():
		hover.set_cell(cell,-1)
	var tile = hover.local_to_map(get_global_mouse_position() - Vector2(0,8))
	
	hover.set_cell(tile,1,Vector2i(0,0))
	
	if Input.is_action_just_pressed("ui_accept"):
		var house = HOUSE.instantiate()
		house.global_position = hover.map_to_local(tile + Vector2i(1,1))
		get_parent().add_child(house)
		is_building = false
	pass
