extends Node2D
class_name BuildMap

const HOUSE = preload("res://Buildings/Scenes/house.tscn")
const STORAGE = preload("res://Buildings/Scenes/storage.tscn")
const BUILDING = preload("res://Buildings/Scenes/construction.tscn")
const DROP = preload("res://TileMap/Scenes/resourceDrop.tscn")

@onready var grass: TileMapLayer = $Grass
@onready var tree: TileMapLayer = $Tree
@onready var hover: TileMapLayer = $Hover
@onready var hover2: TileMapLayer = %Hover2
@onready var drawingNode: Node2D = %DrawingNode
@onready var roads: TileMapLayer = $Roads
@onready var buildings_node : Node2D = get_tree().get_first_node_in_group("BUILDINGS_NODE")

var is_building : bool = false

var xdim : int = 2
var ydim : int = 2
var cost : int = 0
var resource : Global.RESOURCES_TRACKED
var type : Global.BUILDINGS

var aStar : AStarGrid2D = AStarGrid2D.new()

func _ready() -> void:
	_set_road_weights()
	_remove_tree_nav()
	
	
func _process(_delta: float) -> void:
	for cell in hover.get_used_cells():
		hover.set_cell(cell,-1)
	for cell in hover2.get_used_cells():
		hover2.set_cell(cell,-1)
	
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
	if type >= Global.BUILDINGS.FARM:
		is_building = false
		drawingNode.type = type
		return
	
	var tile : Vector2i = hover.local_to_map(get_global_mouse_position() - Vector2(0,8))
	hover.set_cell(tile,type,Vector2i(0,0))
	var hoverTiles = hoverHelper(tile,2,3)
	hover2.set_cells_terrain_connect(hoverTiles,0,0)
	
	if Input.is_action_just_pressed("confirm"):
		if Global.inventory_dict[resource] < cost:
			is_building = false
			return
		
		var building = BUILDING.instantiate()
		building.global_position = hover.map_to_local(tile + Vector2i(1,1))
		building.building = type
		buildings_node.add_child(building)
		
		is_building = false
		Global.inventory_dict[resource] -= cost
	
	if Input.is_action_just_pressed("cancel"):
		is_building = false
		type = 0
	pass

func hoverHelper(tile : Vector2i, xDim : int, yDim : int) -> Array:
	var arr = []
	for x in range(tile.x + 1, tile.x + xDim + 1):
		for y in range(tile.y +1, tile.y + yDim + 1):
			arr.append(Vector2i(x,y))
	return arr

func _set_road_weights() -> void:
	# Astar algorithm setting
	aStar.region = Rect2i(grass.get_used_rect())
	aStar.cell_shape = AStarGrid2D.CELL_SHAPE_ISOMETRIC_DOWN
	aStar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	aStar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	aStar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
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

func spawn_resource(initPos : Vector2i, resourcetype : Global.RESOURCES_TRACKED):
	var drop_instance = DROP.instantiate()
	var launch_speed = 100
	var launch_time = .25
	drop_instance.type = resourcetype
	add_child(drop_instance)
	
	var pos = grass.map_to_local(initPos)
	drop_instance.global_position = pos
	
	var direction : Vector2 = Vector2(
		randi_range(-1.0,1.0),
		randi_range(-1.0,1.0)
	).normalized()
	
	drop_instance.launch(direction * launch_speed, launch_time)
