extends Node2D
class_name BuildMap

const HOUSE = preload("res://Buildings/Scenes/house.tscn")
const STORAGE = preload("res://Buildings/Scenes/storage.tscn")

@onready var grass: TileMapLayer = $Grass
@onready var tree: TileMapLayer = $Tree
@onready var hover: TileMapLayer = $Hover

var is_building : bool = false

var xdim : int = 2
var ydim : int = 2
var cost : int = 0
var type : int = 0

func _process(delta: float) -> void:
	for cell in hover.get_used_cells():
		hover.set_cell(cell,-1)
	#print(is_building)
	if is_building:
		_handle_hover()
	pass

func set_build_settings(xd : int, yd : int, c : int, t : int):
	xdim = xd
	ydim = yd
	cost = c
	type = t
	print(type)
	is_building = true

func _handle_hover() -> void:
	var tile : Vector2i = hover.local_to_map(get_global_mouse_position() - Vector2(0,8))
	hover.set_cell(tile,type,Vector2i(0,0))
	
	if Input.is_action_just_pressed("confirm"):
		if Global.wood < cost:
			is_building = false
			return
		
		_build_chosen_building(tile)
		is_building = false
		Global.wood -= cost
		
	pass

func _build_chosen_building(tile):
	match type: # type of building
		1: # House
			var house = HOUSE.instantiate()
			house.global_position = hover.map_to_local(tile + Vector2i(1,1))
			get_parent().add_child(house)
		2: # Storage
			var storage = STORAGE.instantiate()
			storage.global_position = hover.map_to_local(tile + Vector2i(1,1))
			get_parent().add_child(storage)
