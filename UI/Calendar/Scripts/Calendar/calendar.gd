extends Control

@onready var days_label: Label = $DayControl/days
@onready var hours_label: Label = $ClockControl/hours 
@onready var minutes_label: Label = $ClockControl/minutes

var calendar_sprite = preload("res://UI/Calendar/Calendar_Menu.tscn")
@onready var instance

# Updates the labels on the canvas to show time in game.
func _on_time_system_updated(date_time:DateTime) -> void:
	update_label(days_label,date_time.days,false)
	update_label(hours_label,date_time.hours)
	update_label(minutes_label,date_time.minutes)
	
func add_leading_zero(label: Label, value: int) -> void:
	if value < 10:
		label.text += '0'
		
func update_label(label: Label, value: int, leading_zero: bool = true) -> void:
	label.text = ""
	if leading_zero:
		add_leading_zero(label,value)
	label.text += str(value)

func Calendar_Pressed() -> void:
	if !is_instance_valid(instance):
		instance = calendar_sprite.instantiate()
		add_child(instance)
		var pos_x = size.x - instance.size.x 
		var pos_y = size.y - instance.size.y
		instance.position = Vector2(pos_x,pos_y)/2
	else:
		print("Calendar is already visible")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("ui_cancel"):
		close_calendar()

func close_calendar() -> void:
	if Input.is_key_pressed(KEY_ESCAPE) and is_instance_valid(instance):
		instance.queue_free()
