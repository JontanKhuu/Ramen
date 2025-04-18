extends Node2D

const FARM_BUILDING = preload("res://Buildings/Scenes/FarmOutline.tscn")

@onready var hover : TileMapLayer = get_parent()

var is_farm_building : bool = false
var is_drawing : bool = false
var selectionStartPoint : Vector2 = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("confirm") && is_farm_building:
		selectionStartPoint = get_global_mouse_position()
		is_drawing = true

func _process(delta: float) -> void:
	if is_drawing:
		var mousePos = hover.local_to_map(get_global_mouse_position())
		var selectPos = hover.local_to_map(selectionStartPoint)
		
		var stepX = 1 if selectPos.x < mousePos.x else -1
		var stepY = 1 if selectPos.y < mousePos.y else -1
		
		for x in range(selectPos.x + stepX ,mousePos.x + stepX, stepX):
			for y in range(selectPos.y + stepY ,mousePos.y + stepY, stepY):
				hover.set_cell(Vector2i(x,y),0,Vector2i(0,0))
				
		if Input.is_action_just_released("confirm"):
			create_building(selectPos,mousePos)
			is_drawing = false
			is_farm_building = false

func create_building(startPos, endPos) -> void:
	var offset : int = 8
	var dirX = 1 if startPos.x < endPos.x else -1
	var dirY = 1 if startPos.y < endPos.y else -1
	
	# finding points
	var start = hover.map_to_local(startPos)
	var end = hover.map_to_local(endPos)
	var sideOne = hover.map_to_local(Vector2i(startPos.x,endPos.y))
	var sideTwo = hover.map_to_local(Vector2i(endPos.x,startPos.y))
	
	var arr : PackedVector2Array = []
	
	# setting line and polygon points for area
	var farmBuilding = FARM_BUILDING.instantiate()
	get_node("/root/World").add_child(farmBuilding)
	arr.append(start  )
	arr.append(sideOne)
	arr.append(end )
	arr.append(sideTwo )
	farmBuilding.colShape.polygon = arr
	farmBuilding.line.points = arr
	#farmBuilding.global_position = (end + start) / 2
	pass
