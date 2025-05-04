extends CharacterBody2D

const NPC = preload("res://NPC/Scenes/npc.tscn")

@export var target : Vector2
@export var deliveryPoint : Vector2
@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var NPCs : Node = get_node("/root/World/NPCs")

var delivered : bool = false

func _process(delta: float) -> void:
	sprite.play("default")
	velocity = global_position.direction_to(target) * 200
	if global_position.distance_to(deliveryPoint) < 10 and !delivered:
		var npc = NPC.instantiate()
		npc.global_position = deliveryPoint
		npc.velocity = Vector2(0,100)
		npc.job = Global.JOB.NONE
		NPCs.add_child(npc)
		delivered = true
		pass
	
	move_and_slide()
	pass
