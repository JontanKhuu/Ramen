extends CharacterBody2D

@export var target : Vector2

func _process(delta: float) -> void:
	velocity = global_position.direction_to(target) * 200
	pass
