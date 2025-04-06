extends UtilityAiConsideration

@export var job : String

@onready var player = get_node("/root/World/NPC")

func _ready() -> void: 
	print(player.job)

func score() -> float:
	job = player.job
	if job == "LABORER":
		return 1.0 
	return 0.0
