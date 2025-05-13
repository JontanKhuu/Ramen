extends Node

const jobBox = preload("res://UI/Job_Manager/job_box.tscn")

@onready var available_workers: Label = $"Job Manager Box/Job/Job Container/Job Count"
@onready var job_manager = $"Job Manager Box"
@onready var jobs = Global.JOB
@onready var job_container = VBoxContainer.new()
var current_job_counts: Dictionary = {} # Keep track of the current number of villagers in each job

func _ready():
	var initial_job_counts = _get_initial_job_counts()
	available_workers.text = str(initial_job_counts[jobs.NONE]) # Display initial unemployed count
	job_manager.add_child(job_container)
	_create_job_spinboxes(initial_job_counts) # Pass initial job counts
	_connect_spinbox_signals()
	_update_spinbox_max_values() # Setting initial max values
	Global.connect("adult_count_increased", _update_spinbox_max_values)

func _get_initial_job_counts() -> Dictionary:
	var job_counts = {}
	for job_name in jobs.keys():
		job_counts[jobs[job_name]] = _get_villager_job(jobs[job_name]).size()
	return job_counts

func _get_villager_job(job_enum: int) -> Array:
	var all_villagers = get_tree().get_nodes_in_group("VILLAGER")
	var filtered_villagers = []
	for villager in all_villagers:
		if villager.job == job_enum:
			filtered_villagers.append(villager)
	return filtered_villagers

func _create_job_spinboxes(initial_job_counts: Dictionary):
	var total_villagers = 0
	for count in initial_job_counts.values():
		total_villagers += count

	for job_name in jobs.keys():
		var job_enum_value = jobs[job_name]
		if job_enum_value != jobs.NONE and job_enum_value != jobs.CHILD:
			var spinbox = jobBox.instantiate()
			spinbox.name = job_name # Use the job name directly
			spinbox.alignment = HORIZONTAL_ALIGNMENT_CENTER
			spinbox.prefix = job_name.to_lower().capitalize() + "s:"
			spinbox.max_value = total_villagers # Initial max is total villagers
			spinbox.value = initial_job_counts.get(job_enum_value, 0) # Set initial value
			spinbox.type = Global.job_name_dict.find_key(job_name)
			job_container.add_child(spinbox)
			current_job_counts[job_name] = spinbox.value # Initialize count

func _connect_spinbox_signals():
	for child in job_container.get_children():
		if child is SpinBox:
			child.value_changed.connect(_on_job_spinbox_changed.bind(child))

func _update_spinbox_max_values():
	var unemployed_count = _get_villager_job(jobs.NONE).size()
	var total_villagers = unemployed_count
	for count in current_job_counts.values():
		total_villagers += count

	for child in job_container.get_children():
		var job_name = child.name
		var current_assigned = current_job_counts.get(job_name, 0)
		var altLim = current_assigned + unemployed_count
		
		if child.name != "NONE" or child.name == "CHILD":
			child.max_value = altLim
			continue
		if child is JobBox:
			var lim = Global.job_limit_dict[child.type]
			if lim < altLim:
				child.max_value = lim
			else:
				child.max_value = altLim

func _on_job_spinbox_changed(new_value: float, spinbox):
	Global.update_job_limits()
	var job_name = spinbox.name
	var previous_value = current_job_counts.get(job_name, 0)
	var difference = int(new_value - previous_value)
	
	if difference > 0:
		var unemployed = _get_villager_job(jobs.NONE)
		var villagers_to_add = min(difference, unemployed.size())
		for _i in villagers_to_add:
			if not unemployed.is_empty():
				var current_villager = unemployed.pop_front()
				current_villager.job = jobs[job_name]
	elif difference < 0:
		var current_job_enum = jobs[job_name]
		var current_job_villagers = _get_villager_job(current_job_enum)
		var villagers_to_remove = min(-difference, current_job_villagers.size())
		for _i in villagers_to_remove:
			if not current_job_villagers.is_empty():
				var current_villager = current_job_villagers.pop_front()
				current_villager.job = jobs.NONE

	current_job_counts[job_name] = int(new_value)
	available_workers.text = str(_get_villager_job(jobs.NONE).size())
	_update_spinbox_max_values() # Update max values after each change
