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

func mark_for_demolish() -> void:
	pass
