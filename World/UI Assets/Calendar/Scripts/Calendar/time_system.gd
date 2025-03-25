class_name TimeSystem extends Node 

signal updated

@export var date_time: DateTime 
@export var ticks_per_second: int = 6 # Change the int here to increase/decrease speed of time

# Function that updates time
func _process(delta:float) -> void:
	date_time.increase_by_sec(delta * ticks_per_second)
	updated.emit(date_time)
