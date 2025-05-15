extends Control

@onready var main_button: TextureButton = $MainButton
@onready var pop_out_container: Control = $PopOutContainer
@onready var calendar_instance
@onready var job_manager_instance 
@onready var npc_stats_instance
@onready var inventory_instance
@onready var event_log_instance


@export var drag_sensitivity: float = 0.01 # Adjust for drag speed
@export var pop_out_distance: float = 115.0 # Distance from the Main Button

var is_popped_out: bool = false
var num_buttons: int = 0

var is_mouse_down: bool = false
var current_rotation: float = 0.0
var last_mouse_position: Vector2

const calendar_sprite = preload("res://UI/Calendar/Calendar_Menu.tscn")
const npc_stats = preload("res://NPC/Scenes/npc_stats.tscn")
const job_manager = preload("res://UI/Job_Manager/Job_Manager.tscn")
const inventory = preload("res://UI/Inventory/Inventory.tscn")
const event_log = preload("res://UI/Logs/LogInfo.tscn")

func _ready():
	main_button.connect("pressed", self._on_main_button_pressed)
	num_buttons = pop_out_container.get_child_count()
	pop_out_container.visible = false
	set_process(false)
	set_process_input(true)

func _on_main_button_pressed():
	is_popped_out = !is_popped_out
	pop_out_container.visible = is_popped_out
	set_process(is_popped_out)
	if is_popped_out:
		_position_circular_buttons()
		_position_pop_out_container()
		current_rotation = 0.0

func _position_pop_out_container(): # Position the PopOutContainer (Not actual container) to be centered on mainbutton
	var main_button_center: Vector2 = main_button.global_position + (main_button.size * main_button.scale / 2)
	var pop_out_container_size: Vector2 = pop_out_container.size
	pop_out_container.global_position = main_button_center - (pop_out_container_size / 2)

func _position_circular_buttons(): # Positioning the smaller buttons around main button
	if num_buttons == 0:
		return

	var main_button_rect = get_global_rect()
	var main_button_center: Vector2 = main_button_rect.position + (main_button.size / 2)
	var main_button_effective_radius: float = max(main_button.size.x, main_button.size.y) / 2.0
	var effective_orbit_radius: float = main_button_effective_radius + pop_out_distance
	var angle_increment: float = TAU/ float(num_buttons)

	for i in range(num_buttons):
		var button = pop_out_container.get_child(i)
		var angle: float = angle_increment * float(i) + current_rotation
		var button_x: float = effective_orbit_radius * cos(angle) - (button.size.x / 2)
		var button_y: float = effective_orbit_radius * sin(angle) - (button.size.y / 2)
		button.position = Vector2(button_x, button_y)

func _input(event): # If mouse button left is held down buttons will rotate.
	if is_popped_out:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				is_mouse_down = event.pressed
				if is_mouse_down:
					last_mouse_position = get_global_mouse_position()
		elif event is InputEventMouseMotion and is_mouse_down:
			var current_mouse_position = get_global_mouse_position()
			var drag_distance = current_mouse_position.x - last_mouse_position.x 
			current_rotation -= drag_distance * drag_sensitivity
			last_mouse_position = current_mouse_position
			_position_circular_buttons()

func close_calendar() -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		calendar_instance.queue_free()

func close_job_manager() -> void:
	job_manager_instance.queue_free()
	
func close_npc_stats() -> void:
	npc_stats_instance.queue_free()
	
func close_inventory() -> void:
	inventory_instance.queue_free()
	
func close_event_log() -> void:
	event_log_instance.queue_free()
		
func _unhandled_input(event: InputEvent) -> void: # Close all pop up instances
	if event.is_action("ui_cancel"):
		if is_instance_valid(calendar_instance):
			close_calendar()
		if is_instance_valid(job_manager_instance):
			close_job_manager()
		if is_instance_valid(npc_stats_instance):
			close_npc_stats()
		if is_instance_valid(inventory_instance):
			close_inventory()
		if is_instance_valid(event_log_instance):
			close_event_log()
		
func _on_calendar_button_pressed() -> void:
	if !is_instance_valid(calendar_instance):
		calendar_instance = calendar_sprite.instantiate()
		add_child(calendar_instance)
		var pos_x = size.x - calendar_instance.size.x 
		var pos_y = size.y - calendar_instance.size.y
		calendar_instance.position = Vector2(pos_x,pos_y)/2
	else:
		print ("Calendar is already visible")
		
func _on_villager_stats_button_pressed() -> void:
	if !is_instance_valid(npc_stats_instance):
		npc_stats_instance = npc_stats.instantiate()
		add_child(npc_stats_instance)
	else:
		print ("NPC stats is already visible, closing")
		close_npc_stats()

func _on_villager_employment_pressed() -> void:
	if !is_instance_valid(job_manager_instance):
		job_manager_instance = job_manager.instantiate()
		add_child(job_manager_instance)
	else:
		print ("Job Manager is already visible, closing")
		close_job_manager()


func _on_inventory_button_pressed() -> void:
	if !is_instance_valid(inventory_instance):
		inventory_instance = inventory.instantiate()
		add_child(inventory_instance)
	else:
		print ("Inventory is already visible, closing")
		close_inventory()

func _on_logs_button_pressed() -> void:
	if !is_instance_valid(event_log_instance):
		event_log_instance = event_log.instantiate()
		add_child(event_log_instance)
	else:
		print ("Event log is already visible, closing")
		close_event_log()
