extends Node2D

const FARM_BUILDING = preload("res://Buildings/Scenes/FarmOutline.tscn")
const CROP = preload("res://TileMap/Scenes/crop.tscn")

@onready var tiles : Node2D = owner
@onready var hover : TileMapLayer = get_parent()
@onready var grass : TileMapLayer = owner.get_child(0)
@onready var tree : TileMapLayer = owner.get_child(1)
@onready var cropNode : Node2D = get_node("/root/World/Crops")
@onready var roads: TileMapLayer = %Roads

var type : Global.BUILDINGS
var is_drawing : bool = false
var selectionStartPoint : Vector2 = Vector2.ZERO

var road_tiles : Array = []
var used_tiles : Array = []
	
# starting and end points
var mousePos
var selectPos

# directions for creating area
var stepX
var stepY

func _input(event: InputEvent) -> void:
	# right clickt to cancel, left click to start drawing
	if Input.is_action_just_pressed("confirm") && (type >= 3):
		selectionStartPoint = get_global_mouse_position()
		is_drawing = true
	if Input.is_action_just_pressed("cancel"):
		tiles.building = false
		is_drawing = false
	# if dragged area is released, build
	if event.is_action_released("confirm") and is_drawing:
		used_tiles = grass.get_used_cells_by_id(0,Vector2i(0,1),1)
		match type:
			Global.BUILDINGS.FARM:
				create_building(selectPos,mousePos,stepX,stepY)
			Global.BUILDINGS.HARVEST:
				mark_for_demolish(selectPos,mousePos,stepX,stepY)
			Global.BUILDINGS.ROAD:
				build_roads(road_tiles)
		type = Global.BUILDINGS.NONE
		is_drawing = false
		
func _process(delta: float) -> void:
	if is_drawing:
		_handle_drawing()

func _handle_drawing() -> void:
	mousePos = hover.local_to_map(get_global_mouse_position())
	selectPos = hover.local_to_map(selectionStartPoint)
	
	stepX = 1 if selectPos.x < mousePos.x else -1
	stepY = 1 if selectPos.y < mousePos.y else -1
	
	if type == Global.BUILDINGS.ROAD:
		road_tiles = hover_roads(selectPos,mousePos,stepX,stepY)
		return
	
	for x in range(selectPos.x ,mousePos.x, stepX):
		for y in range(selectPos.y ,mousePos.y , stepY):
			hover.set_cell(Vector2i(x,y),0,Vector2i(0,0))
	
func _unhandled_input(event: InputEvent) -> void:
	pass

func create_building(startPos, endPos, stepX, stepY) -> void:
	# if no area is drawn then make one tile
	if startPos == endPos and !used_tiles.has(startPos):
		var pos = grass.map_to_local(startPos)
		var crop = CROP.instantiate()
		cropNode.add_child(crop)
		crop.global_position = pos
		return
	
	# sets tiles to farm tiles
	for x in range(startPos.x ,endPos.x, stepX):
		for y in range(startPos.y ,endPos.y , stepY):
			if used_tiles.has(Vector2i(x,y)):
				continue
			var pos = grass.map_to_local(Vector2i(x,y))
			var crop = CROP.instantiate()
			cropNode.add_child(crop)
			crop.global_position = pos
	
	Global.update_job_limits()
	pass

func mark_for_demolish(startPos, endPos, stepX, stepY) -> void:
	# Marking resources for demolish
	var treeTiles = tree.get_used_cells_by_id(0,Vector2i(0,0))
	var stoneTiles = tree.get_used_cells_by_id(1,Vector2i(0,0))
	if startPos == endPos:
		if treeTiles.has(startPos):
			tree.set_cell(startPos,0,Vector2i(0,0),1)
		elif stoneTiles.has(startPos):
			tree.set_cell(startPos,1,Vector2i(0,0),1)
		
	for x in range(startPos.x ,endPos.x, stepX):
		for y in range(startPos.y ,endPos.y , stepY):
			if treeTiles.has(Vector2i(x,y)):
				tree.set_cell(Vector2i(x,y),0,Vector2i(0,0),1)
			elif stoneTiles.has(Vector2i(x,y)):
				tree.set_cell(Vector2i(x,y),1,Vector2i(0,0),1)

func hover_roads(selectPos,mousePos,stepX,stepY) -> Array:
	var arr : Array = []
	if selectPos == mousePos:
		hover.set_cell(selectPos,0,Vector2i(0,0))
		arr.append(selectPos)
	
	for x in range(selectPos.x ,mousePos.x, stepX):
		hover.set_cell(Vector2i(x,mousePos.y),0,Vector2i(0,0))
		arr.append(Vector2i(x,mousePos.y))
	for y in range(selectPos.y ,mousePos.y , stepY):
		hover.set_cell(Vector2i(selectPos.x,y),0,Vector2i(0,0))
		arr.append(Vector2i(selectPos.x,y))
	
	return arr

func build_roads(road_tiles : Array) -> void:
	road_tiles = road_tiles.filter(func(element): return !used_tiles.has(element))
	roads.set_cells_terrain_connect(road_tiles,0,0)
	tiles._set_road_weights()
	pass
