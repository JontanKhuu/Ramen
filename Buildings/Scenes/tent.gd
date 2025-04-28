extends House
class_name tent

@onready var entrance: Node2D = $Entrance

func _ready() -> void:
	bed = entrance
	assign_homes()
