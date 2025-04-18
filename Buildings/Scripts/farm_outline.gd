extends Area2D

@onready var colShape : CollisionPolygon2D = %shape
@onready var line: Line2D = $Line2D

func _process(delta: float) -> void:
	print(colShape.polygon)

#func _on_mouse_entered() -> void:
	#visible = true
#
#func _on_mouse_exited() -> void:
	#visible = false
