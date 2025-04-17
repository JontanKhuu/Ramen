extends Node2D

@onready var hover : TileMapLayer = get_parent()

var is_farm_building : bool = false
var is_drawing : bool = false
var selectionStartPoint : Vector2 = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.button_index == 1 && event.is_pressed()) && is_farm_building:
			selectionStartPoint = get_global_mouse_position()
			is_drawing = true

func _process(delta: float) -> void:
	if is_drawing:
		var mousePos = hover.local_to_map(get_global_mouse_position())
		var selectPos = hover.local_to_map(selectionStartPoint)
		
		var stepX = 1 if selectPos.x < mousePos.x else -1
		var stepY = 1 if selectPos.y < mousePos.y else -1
		
		for x in range(selectPos.x,mousePos.x, stepX):
			for y in range(selectPos.y,mousePos.y, stepY):
				hover.set_cell(Vector2i(x,y),0,Vector2i(0,0))
				
		if Input.is_action_just_released("confirm"):
			is_drawing = false
			is_farm_building = false
