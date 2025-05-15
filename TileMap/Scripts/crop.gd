extends Node2D
class_name Crop

@export var growth_time : float = 5.0
@export var planted : bool = false
@export var grown : bool  = false
@export var amount : int = 2

@onready var sprite: Sprite2D = $Sprite2D
@onready var bar: ProgressBar = $ProgressBar


var time = 0.0

func _ready() -> void:
	bar.max_value = growth_time

func _process(delta: float) -> void:
	if time < growth_time && planted:
		time += delta
	elif time >= growth_time:
		grow()
		
	bar.value = time
	var percentage = (bar.value / bar.max_value) * 100
	if !planted:
		sprite.frame = 0
	elif percentage < 33 and planted:
		sprite.frame = 1
	elif percentage < 66 and planted:
		sprite.frame = 2
	
	if get_global_mouse_position().distance_to(global_position) < 10:
		bar.visible = true
	else:
		bar.visible = false

func grow() -> void:
	grown = true
	sprite.frame = 3
	# change sprite
	pass
