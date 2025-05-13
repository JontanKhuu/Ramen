extends StaticBody2D
class_name Drops

@onready var sprite: Sprite2D = $Sprite2D
var frame : int
@export var type : Global.RESOURCES_TRACKED
@export var amount : int

var launch_velocity : Vector2 = Vector2.ZERO
var move_duration : float = 0
var time_since_launch : float = 0
var launching : bool = false :
	set(is_launching):
		launching = is_launching


func _ready() -> void:
	match type:
		Global.RESOURCES_TRACKED.BERRIES:
			frame = 0
		Global.RESOURCES_TRACKED.HIDES:
			frame = 1
		Global.RESOURCES_TRACKED.STONE:
			frame = 2
		#Global.RESOURCES_TRACKED.FISH:
			#frame = 3
		#Global.RESOURCES_TRACKED.IRoN:
			#frame = 4
		Global.RESOURCES_TRACKED.VENISON:
			frame = 5
		Global.RESOURCES_TRACKED.WOOD:
			frame = 6
	sprite.frame = frame

func _process(delta):
	if(launching):
		position += launch_velocity * delta
		time_since_launch += delta
		
		if(time_since_launch >= move_duration):
			launching = false

func launch(velocity : Vector2, duration : float):
	launch_velocity = velocity
	move_duration = duration 
	time_since_launch = 0
	launching = true
