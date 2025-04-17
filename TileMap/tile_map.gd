extends Node2D
class_name BuildMap

const HOUSE = preload("res://Buildings/Scenes/house.tscn")
const STORAGE = preload("res://Buildings/Scenes/storage.tscn")
const BUILDING = preload("res://Buildings/Scenes/construction.tscn")

@onready var grass: TileMapLayer = $Grass
@onready var tree: TileMapLayer = $Tree
@onready var hover: TileMapLayer = $Hover

var is_building : bool = false

var xdim : int = 2
var ydim : int = 2
var cost : int = 0
var resource : Global.RESOURCES_TRACKED
var type : int = 0

func _process(delta: float) -> void:
	for cell in hover.get_used_cells():
		hover.set_cell(cell,-1)
	#print(is_building)
	
	if is_building:
		_handle_hover()
	pass

func set_build_settings(xd : int, yd : int, c : int, t : int, r : Global.RESOURCES_TRACKED):
	xdim = xd
	ydim = yd
	cost = c
	type = t
	resource = r
	print(type)
	is_building = true

func _handle_hover() -> void:
	var tile : Vector2i = hover.local_to_map(get_global_mouse_position() - Vector2(0,8))
	hover.set_cell(tile,type,Vector2i(0,0))
	
	if Input.is_action_just_pressed("confirm"):
		if Global.inventory_dict[resource] < cost:
			is_building = false
			return
		
		var building = BUILDING.instantiate()
		building.global_position = hover.map_to_local(tile + Vector2i(1,1))
		building.building = type
		get_parent().add_child(building)
		
		is_building = false
		Global.inventory_dict[resource] -= cost
		
	pass
