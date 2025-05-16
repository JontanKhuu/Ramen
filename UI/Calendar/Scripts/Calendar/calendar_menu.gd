extends Control

@onready var time_system: TimeSystem = get_node("/root/World/TimeSystem")
@export var event_indicator_scene: PackedScene 
@export var event_details_panel_scene: PackedScene

var current_event_details_panel 
var eventlog

func _on_gui_input(event: InputEvent) -> void:
	get_parent().close_calendar()

func _ready():
	_populate_calendar()
	_display_event_buttons()
	eventlog = get_tree().get_first_node_in_group("EVENTLOG")

func _populate_calendar():
	var day_container = $NinePatchRect/GridContainer
	for i in range(28):
		var day_button = Button.new()
		day_button.flat = true
		day_container.add_child(day_button)

func _display_event_buttons():
	var day_container = $NinePatchRect/GridContainer
	var events_by_day = {}
	for event_name in time_system.events:
		var event_data = time_system.events[event_name]
		var event_day = event_data.days
		if event_day >= 1 and event_day <= 28:
			if !events_by_day.has(event_day):
				events_by_day[event_day] = []
			events_by_day[event_day].append(event_name)

	for i in range(day_container.get_child_count()):
		var day_button = day_container.get_child(i) as Button
		var day = i + 1
		if events_by_day.has(day):
			if event_indicator_scene:
				var event_button_instance = event_indicator_scene.instantiate()
				if event_button_instance is Button:
					event_button_instance.connect("pressed", _on_show_day_events.bind(day))
					day_button.add_child(event_button_instance)
					# Adjust position to place the "Events" button appropriately within the day button
					event_button_instance.position = Vector2(50, 0) 

func _on_show_day_events(day: int):
	if is_instance_valid(current_event_details_panel):
		current_event_details_panel.queue_free()
		
	var events_for_day = []
	for event_name in time_system.events:
		if typeof(time_system.events[event_name]) == TYPE_DICTIONARY:
			if time_system.events[event_name]["days"] == day:
				if typeof(time_system.events[event_name]["hours"]) == TYPE_INT and typeof(time_system.events[event_name]["minutes"]) == TYPE_INT:
					events_for_day.append({
						"name": event_name,
						"hour": time_system.events[event_name]["hours"],
						"minute": time_system.events[event_name]["minutes"]
					})
					
	events_for_day.sort_custom(func(a, b):
		if a.hour != b.hour:
			return a.hour < b.hour
		return a.minute < b.minute
	)
	_display_event_list(day, events_for_day)

func _display_event_list(day: int, events: Array):
	if event_details_panel_scene:
		var details_panel_instance = event_details_panel_scene.instantiate()
		var event_list_container = eventlog.events
		#details_panel_instance.get_node("EventPanel/EventContainer") 
		#var title_label = details_panel_instance.get_node("EventPanel/EventsLabel") 
		#var close_button = details_panel_instance.get_node("ClosePanel")
		if is_instance_valid(event_list_container):
			#for child in event_list_container.get_children():
				#child.queue_free()
			for event in events:
				var event_label = RichTextLabel.new()
				event_label.scale = Vector2(0.75,0.75)
				event_label.custom_minimum_size = Vector2(175,20)
				event_label.fit_content = true
				event_label.bbcode_enabled = true
				event_label.z_index = 10
				var formatted_time = "%02d:%02d" % [event.hour, event.minute]
				event_label.text = "%s - %s" % [event.name, formatted_time]
				event_label.text = "[color=yellow]" + event_label.text + "[/color]" 
				event_list_container.add_child(event_label)

		#if is_instance_valid(close_button):
			#close_button.connect("pressed", _on_event_details_close_pressed.bind(details_panel_instance))

		#current_event_details_panel = details_panel_instance
		#add_child(current_event_details_panel)

func _on_event_details_close_pressed(panel_instance: Node):
	if is_instance_valid(panel_instance):
		panel_instance.queue_free()
