extends Node2D

const FARM_BUILDING = preload("res://Buildings/Scenes/FarmOutline.tscn")
const CROP = preload("res://TileMap/Scenes/crop.tscn")

@onready var hover : TileMapLayer = get_parent()
@onready var grass : TileMapLayer = get_parent().get_parent().get_child(0)
@onready var cropNode : Node2D = get_node("/root/World/Crops")

var is_farm_building : bool = false
var is_drawing : bool = false
var selectionStartPoint : Vector2 = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("confirm") && is_farm_building:
		selectionStartPoint = get_global_mouse_position()
		is_drawing = true

func _process(delta: float) -> void:
	if is_drawing:
		# starting and end points
		var mousePos = hover.local_to_map(get_global_mouse_position())
		var selectPos = hover.local_to_map(selectionStartPoint)
		
		# directions for creating area
		var stepX = 1 if selectPos.x < mousePos.x else -1
		var stepY = 1 if selectPos.y < mousePos.y else -1
		
		# if dragged area is released, build
		if Input.is_action_just_released("confirm"):
			create_building(selectPos,mousePos,stepX,stepY)
			is_drawing = false
			is_farm_building = false
			
		for x in range(selectPos.x ,mousePos.x, stepX):
			for y in range(selectPos.y ,mousePos.y , stepY):
				hover.set_cell(Vector2i(x,y),0,Vector2i(0,0))
				

func create_building(startPos, endPos, stepX, stepY) -> void:
	# sets tiles to farm tiles
	for x in range(startPos.x ,endPos.x, stepX):
		for y in range(startPos.y ,endPos.y , stepY):
			var pos = grass.map_to_local(Vector2i(x,y))
			var crop = CROP.instantiate()
			cropNode.add_child(crop)
			crop.global_position = pos
			
	# offset because lines were weird
	match stepX + stepY:
		0:
			if stepX < 0:
				startPos += Vector2i(stepX,stepY)
				endPos += Vector2i(stepX,stepY)
			else:
				startPos -= Vector2i(stepX,stepY)
				endPos -= Vector2i(stepX,stepY)
		2:
			print("wow")
			startPos -= Vector2i(stepX,stepY)
			endPos -= Vector2i(stepX,stepY)
	# finding points
	var start = hover.map_to_local(startPos)
	var end = hover.map_to_local(endPos)
	var sideOne = hover.map_to_local(Vector2i(startPos.x,endPos.y))
	var sideTwo = hover.map_to_local(Vector2i(endPos.x,startPos.y))
	
	var arr : PackedVector2Array = []
	
	# setting line and polygon points for area
	var farmBuilding = FARM_BUILDING.instantiate()
	get_node("/root/World").add_child(farmBuilding)
	arr.append(start)
	arr.append(sideOne)
	arr.append(end )
	arr.append(sideTwo )
	farmBuilding.colShape.polygon = arr
	farmBuilding.line.points = arr
	pass
