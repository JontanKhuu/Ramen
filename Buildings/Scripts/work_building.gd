extends StaticBody2D
class_name Workplace

@export var type : Global.WORKPLACE
@export var storage : int
@export var has_worker : bool
@export var has_resoures : bool

@onready var sprite: Sprite2D = $Sprite2D
@onready var prodTimer: Timer = $ProductionTimer

func _ready() -> void:
	set_up_workplace()
	Global.update_job_limits()
	
func _process(delta: float) -> void:
	if has_worker and has_resoures:
		prodTimer.paused = false
	else:
		prodTimer.paused = true
	
func set_up_workplace() -> void:
	match type:
		Global.WORKPLACE.HUNT:
			# switch sprite
			sprite.frame = 0
			pass
		Global.WORKPLACE.CLOTH:
			sprite.frame = 1
			prodTimer.wait_time = 5
			


func _on_production_timer_timeout() -> void:
	match type:
		Global.WORKPLACE.CLOTH:
			Global.inventory_dict[Global.RESOURCES_TRACKED.LEATHER] += 1
			Global.inventory_dict[Global.RESOURCES_TRACKED.HIDES] -= 1
	pass
