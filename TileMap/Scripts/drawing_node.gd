extends Node2D

const FARM_BUILDING = preload("res://Buildings/Scenes/FarmOutline.tscn")
const CROP = preload("res://TileMap/Scenes/crop.tscn")

@onready var hover : TileMapLayer = get_parent()
@onready var grass : TileMapLayer = owner.get_child(0)
@onready var tree : TileMapLayer = owner.get_child(1)
@onready var cropNode : Node2D = get_node("/root/World/Crops")

var is_farm_building : bool = false
var is_removing : bool = false
var is_drawing : bool = false
var selectionStartPoint : Vector2 = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("confirm") && (is_farm_building or is_removing):
		selectionStartPoint = get_global_mouse_position()
		is_drawing = true
	if Input.is_action_just_pressed("cancel"):
		is_farm_building = false
		is_removing = false
		is_drawing = false

func _process(delta: float) -> void:
	if is_drawing:
		_handle_drawing()

func _handle_drawing() -> void:
	# starting and end points
	var mousePos = hover.local_to_map(get_global_mouse_position())
	var selectPos = hover.local_to_map(selectionStartPoint)
	
	# directions for creating area
	var stepX = 1 if selectPos.x < mousePos.x else -1
	var stepY = 1 if selectPos.y < mousePos.y else -1
	
	# if dragged area is released, build
	if Input.is_action_just_released("confirm"):
		if is_farm_building:
			create_building(selectPos,mousePos,stepX,stepY)
		elif is_removing:
			mark_for_demolish(selectPos,mousePos,stepX,stepY)
		is_farm_building = false
		is_removing = false
		is_drawing = false
		
	for x in range(selectPos.x ,mousePos.x, stepX):
		for y in range(selectPos.y ,mousePos.y , stepY):
			hover.set_cell(Vector2i(x,y),0,Vector2i(0,0))
	

func create_building(startPos, endPos, stepX, stepY) -> void:
	# if no area is drawn then make one tile
	if startPos == endPos:
		var pos = grass.map_to_local(startPos)
		var crop = CROP.instantiate()
		cropNode.add_child(crop)
		crop.global_position = pos
		return
	
	# sets tiles to farm tiles
	for x in range(startPos.x ,endPos.x, stepX):
		for y in range(startPos.y ,endPos.y , stepY):
			var pos = grass.map_to_local(Vector2i(x,y))
			var crop = CROP.instantiate()
			cropNode.add_child(crop)
			crop.global_position = pos
			
	pass

func mark_for_demolish(startPos, endPos, stepX, stepY) -> void:
	if startPos == endPos and tree.get_used_cells().has(startPos):
		tree.set_cell(startPos,0,Vector2i(0,0),1)
		
	for x in range(startPos.x ,endPos.x, stepX):
		for y in range(startPos.y ,endPos.y , stepY):
			if tree.get_used_cells().has(Vector2i(x,y)):
				tree.set_cell(Vector2i(x,y),0,Vector2i(0,0),1)
	pass
