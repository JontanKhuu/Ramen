class_name DateTime extends Resource 

# Do not touch
@export_range(0,59) var seconds:int = 0
@export_range(0,59) var minutes:int = 0
@export_range(0,59) var hours:int = 0 
@export_range(0,59) var days:int = 0 

signal day_passed

var delta_time: float = 0

# Function for increasing time
func increase_by_sec(delta_seconds:float) -> void:
	delta_time += delta_seconds 
	if delta_time < 1: 
		return 	
	var delta_int_secs: int = delta_time 
	delta_time -= delta_int_secs 
	# Updates time by seconds/minutes/hours/days
	seconds += delta_int_secs 
	minutes += seconds/60 
	hours += minutes/60
	if hours >= 24:
		days += hours/24 
		day_passed.emit()

	seconds = seconds % 60
	minutes = minutes % 60
	hours = hours % 24
	
	if days > 28:
		days = 0
# 	Debugging print statement for time	
#	print_debug(str(days) + ":" + str(hours) + ":" + str(minutes) + ":" + str(seconds))

func diff_without_days(other_time:DateTime) -> int:
	var diff_hours = hours - other_time.hours
	var diff_minutes = minutes - other_time.minutes + diff_hours * 60 
	var diff_seconds = seconds - other_time.seconds + diff_minutes * 60
	return diff_seconds
	
