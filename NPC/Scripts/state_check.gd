@tool
extends UtilityAiConsideration
class_name StateChecker

@export var state : Global.VILLAGER_STATE

@onready var npc = self.owner

func _ready() -> void:
	pass

func score() -> float:
	if npc.state == state:
		return 1.0 
	return 0.0
