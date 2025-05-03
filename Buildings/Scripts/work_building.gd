extends StaticBody2D

@export var type : Global.WORKPLACE

func _ready() -> void:
	set_up_workplace()
	
func set_up_workplace() -> void:
	match type:
		Global.WORKPLACE.HUNT:
			# switch sprite
			# add to job limit 
			pass
