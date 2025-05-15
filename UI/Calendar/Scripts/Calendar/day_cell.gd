extends Button

@export var type = 1
@onready var sprite: Sprite2D = $EventToday

func _ready() -> void:
	match type:
		Global.EVENTS.MERCHANT:
			sprite.frame = 0
		Global.EVENTS.AMBASSADOR:
			sprite.frame = 1
	pass
