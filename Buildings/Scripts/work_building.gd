extends StaticBody2D
class_name Workplace

@export var type : Global.WORKPLACE
@export var has_worker : bool
@export var has_resoures : bool
@export var is_full : bool
@export var storage : Dictionary
@export var max_storage : int
@export var cost : int
@export var productAmount : int
@export var prereq : Global.RESOURCES_TRACKED
@export var prereq2 : Global.RESOURCES_TRACKED
@export var product : Global.RESOURCES_TRACKED
@export var product2 : Global.RESOURCES_TRACKED

@onready var sprite: Sprite2D = $Sprite2D
@onready var prodTimer: Timer = $ProductionTimer
@onready var entrance: Node2D = $Entrance

func _ready() -> void:
	storage = Global.building_inventory_dict.duplicate(false)
	set_up_workplace()
	Global.update_job_limits()
	
func _process(delta: float) -> void:
	#print(storage)
	has_resoures = true if storage[prereq] >= cost else false
	is_full = true if storage[product] >= max_storage else false
	# has_worker is done by npc
	if has_worker and has_resoures and !is_full:
		prodTimer.paused = false
	else:
		prodTimer.paused = true
	
func set_up_workplace() -> void:
	match type:
		Global.WORKPLACE.HUNT:
			# switch sprite
			sprite.frame = 0
		Global.WORKPLACE.CLOTH:
			sprite.frame = 1
			prodTimer.wait_time = 5
			cost = 1
			productAmount = 1
			prereq = Global.RESOURCES_TRACKED.HIDES
			product = Global.RESOURCES_TRACKED.CLOTHES
			

func _on_production_timer_timeout() -> void:
	Global.inventory_dict[product] += productAmount
	Global.inventory_dict[prereq] -= cost
	pass
