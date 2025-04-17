extends UtilityAiConsideration
class_name StateChecker

@export var state : Global.VILLAGER_STATE

@onready var player = get_node("/root/World/NPC")

func _ready() -> void:
	pass

func score() -> float:
	if player.state == state:
		return 1.0 
	return 0.0
