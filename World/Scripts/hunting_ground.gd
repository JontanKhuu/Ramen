extends Area2D

const DEERMAN = preload("res://World/Scenes/deer_man.tscn")

@export var limit : int = 5
@onready var area: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	_spawn_animal()
	pass
	
func _spawn_animal() -> void:
	var deer = DEERMAN.instantiate()
	deer.global_position = global_position
	deer.wander_distance = area.shape.radius
	add_child(deer)
