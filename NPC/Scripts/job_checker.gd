extends UtilityAiConsideration
class_name JobChecker

@export var job : Global.JOB

@onready var player = get_node("/root/World/NPC")

func _ready() -> void:
	pass

func score() -> float:
	if player.job == job:
		return 1.0 
	return 0.0
