extends StaticBody2D
class_name Drops

@export var type : Global.RESOURCES_TRACKED
	#set(type):
		#match type:
			#Global.RESOURCES_TRACKED.WOOD:
				## change sprite
				#pass
@export var amount : int

var launch_velocity : Vector2 = Vector2.ZERO
var move_duration : float = 0
var time_since_launch : float = 0
var launching : bool = false :
	set(is_launching):
		launching = is_launching

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
