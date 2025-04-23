extends Node2D
class_name BuildMap

const HOUSE = preload("res://Buildings/Scenes/house.tscn")
const STORAGE = preload("res://Buildings/Scenes/storage.tscn")
const BUILDING = preload("res://Buildings/Scenes/construction.tscn")

@onready var grass: TileMapLayer = $Grass
@onready var tree: TileMapLayer = $Tree
@onready var hover: TileMapLayer = $Hover
@onready var drawingNode: Node2D = %DrawingNode
@onready var roads: TileMapLayer = $Roads

var is_building : bool = false

var xdim : int = 2
var ydim : int = 2
var cost : int = 0
var resource : Global.RESOURCES_TRACKED
var type : int = 0

var aStar : AStarGrid2D = AStarGrid2D.new()

func _ready() -> void:
	_set_road_weights()
	_remove_tree_nav()
	
	#for x in aStar.size.x :
		#for y in aStar.size.y:
			#aStar.set_point_weight_scale(Vector2i(x,y),.5)
			#grass.set_cell(Vector2i(x,y),0,Vector2i(0,0),1)
	
func _process(delta: float) -> void:
	for cell in hover.get_used_cells():
		hover.set_cell(cell,-1)
	
	if is_building:
		_handle_hover()
	pass

func set_build_settings(xd : int, yd : int, c : int, t : Global.BUILDINGS, r : Global.RESOURCES_TRACKED):
	xdim = xd
	ydim = yd
	cost = c
	type = t
	resource = r
	is_building = true

func _handle_hover() -> void:
	if type == Global.BUILDINGS.FARM:
		drawingNode.is_farm_building = true
		is_building = false
		return
	elif type == Global.BUILDINGS.HARVEST:
		drawingNode.is_removing = true
		is_building = false
		return
	
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

func _set_road_weights() -> void:
	# Astar algorithm setting
	aStar.region = Rect2i(grass.get_used_rect())
	aStar.cell_shape = AStarGrid2D.CELL_SHAPE_ISOMETRIC_DOWN
	aStar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	aStar.update()
	
	var noNav = grass.get_used_cells_by_id(0,Vector2i(0,1),1)
	for cell in noNav:
		aStar.set_point_solid(cell,true)
	
	# apply less weight to roads for usage preference
	var roadTiles = roads.get_used_cells()
	var weightedTiles = grass.get_used_cells()
	weightedTiles = weightedTiles.filter(func(element) : return roadTiles.has(element))
	for tile in grass.get_used_cells():
		aStar.set_point_weight_scale(tile,1)
	for tile in roadTiles:
		grass.set_cell(tile,-1)
		aStar.set_point_weight_scale(tile,.5)
	pass

func _remove_tree_nav() -> void:
	var trees = tree.get_used_cells()
	for cell in trees:
		grass.set_cell(cell,0,Vector2i(0,1),1)
