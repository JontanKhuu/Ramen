extends Node

@onready var available_workers: Label = $Job_Manager_Box/Job/Job_Stuff/Job_Count
@onready var builders_count: Label = $Job_Manager_Box/Builder/Job_Stuff/Job_Count
@onready var laborers_count: Label = $Job_Manager_Box/Laborer/Job_Stuff/Job_Count
@onready var farmers_count: Label = $Job_Manager_Box/Farmer/Job_Stuff/Job_Count
@onready var JOB = Global.JOB

func _ready():
	var job_data = {
		"Builder": Global.JOB.BUILDER,
		"Laborer": Global.JOB.LABORER,
		"Farmer": Global.JOB.FARMER,
	}
	for job_name in job_data.keys():
		var worker_allocation_container = get_node("Job Manager Box/" + job_name + "/Worker Allocation")
		if worker_allocation_container:
			var buttons = worker_allocation_container.get_children()
			for button in buttons:
				if button is Button:
					var amount_text = button.text
					var amount = amount_text.to_int()
					button.connect("pressed", self._on_worker_button_pressed.bind(job_data[job_name], amount))
				else:
					printerr("Warning: Non-button child in Worker Allocation for:", job_name)
		else:
			printerr("Error: Could not find Worker Allocation container for:", job_name)
		update_job_number(job_name, job_data[job_name]) # Initialize job counts for specific jobs
	# Now, also update the "None" job count label
	update_job_number("Job", Global.JOB.NONE)

func get_villager_job(job_enum: int) -> Array:
	var all_villagers = get_tree().get_nodes_in_group("VILLAGER")
	var filtered_villagers = []
	for villager in all_villagers:
		if villager.job == job_enum:
			filtered_villagers.append(villager)
	return filtered_villagers
	
func update_job_number(job_name: String, job_enum: int):
	var job_count_label = get_node("Job Manager Box/" + job_name + "/Job Stuff/Job Count")
	if job_count_label is Label:
		job_count_label.text = str(get_villager_job(job_enum).size())
	else:
		printerr("Error: Could not find Job Count Label for:", job_name)
	
func _on_worker_button_pressed(job_enum: int, amount: int):
	if amount > 0:
		# Add workers to the job
		var jobless_villagers = get_villager_job(Global.JOB.NONE)
		var villagers_to_add = min(amount, jobless_villagers.size())
		for _i in villagers_to_add:
			if not jobless_villagers.is_empty():
				var current_villager = jobless_villagers.pop_front()
				current_villager.job = job_enum
		if villagers_to_add > 0:
			# Need to find the job name to update the label
			for job_name in ["Laborer", "Builder", "Farmer"]:
				if Global.JOB[job_name.to_upper()] == job_enum:
					update_job_number(job_name, job_enum)
					break
			update_job_number("Job", Global.JOB.NONE)
	elif amount < 0:
		# Remove workers from the job
		var current_job_villagers = get_villager_job(job_enum)
		var villagers_to_remove = min(-amount, current_job_villagers.size())
		for _i in villagers_to_remove:
			if not current_job_villagers.is_empty():
				var current_villager = current_job_villagers.pop_front()
				current_villager.job = Global.JOB.NONE
		if villagers_to_remove > 0:
			# Need to find the job name to update the label
			for job_name in ["Laborer", "Builder", "Farmer"]:
				if Global.JOB[job_name.to_upper()] == job_enum:
					update_job_number(job_name, job_enum)
					break
			update_job_number("Job", Global.JOB.NONE)
