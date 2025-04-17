extends DirectionalLight2D

@export var day_color:Color 
@export var afternoon_color:Color
@export var night_color:Color
@export var day_start: DateTime
@export var afternoon_start: DateTime
@export var night_start: DateTime
@export var transition_time: int = 30 #in minutes 
@export var time_system: TimeSystem

var in_transition: bool = false 

enum DayState {DAY,AFTERNOON,NIGHT}
var current_state: DayState = DayState.DAY

# Allows for adding more states to the day later on
@onready var time_map: Dictionary = {
	DayState.DAY : day_start,
	DayState.AFTERNOON : afternoon_start,
	DayState.NIGHT : night_start,
}
# Transition between states, can be used for other day colors, i.e. different color days based on events
@onready var transition_map: Dictionary = {
	DayState.DAY : DayState.AFTERNOON, 
	DayState.AFTERNOON : DayState.NIGHT,
	DayState.NIGHT: DayState.DAY,
}
# Add additional day cycle colors to this dictionary 
@onready var color_map: Dictionary = { 
	DayState.DAY : day_color, 
	DayState.AFTERNOON : afternoon_color,
	DayState.NIGHT : night_color,
}

func _ready() -> void:
	var diff_day_start = time_system.date_time.diff_without_days(day_start)
	var diff_night_start = time_system.date_time.diff_without_days(night_start)
	if diff_day_start < 0 || diff_night_start > 0:
		current_state = DayState.NIGHT

func update(game_time: DateTime) -> void:
	var next_state = transition_map[current_state]
	var change_time = time_map[next_state]
	var time_diff = change_time.diff_without_days(game_time)
	
	if in_transition:
		update_transition(time_diff,next_state)
	elif time_diff > 0 && time_diff < (transition_time * 60):
		in_transition = true 
		update_transition(time_diff,next_state)
	else:
		color = color_map[current_state]
		# update transition
	
func update_transition(time_diff:int, next_state: DayState) -> void:
	var ratio = 1 - (time_diff as float / (transition_time * 60))
	if ratio > 1:
		current_state = next_state
		in_transition = false
		update_villager_states() # update villager actions according to time
	else: 
		color = color_map[current_state].lerp(color_map[next_state],ratio)
	

func update_villager_states():
	match current_state:
		DayState.DAY:
			print("why")
			Global.set_villagers_state(Global.VILLAGER_STATE.WORKING)
		DayState.AFTERNOON:
			print("why2")
			Global.set_villagers_state(Global.VILLAGER_STATE.RESTING)
		DayState.NIGHT:
			print("why3")
			Global.set_villagers_state(Global.VILLAGER_STATE.SLEEPING)
		
		
		
