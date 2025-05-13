extends CanvasLayer

@onready var camera_2d = get_node("/root/World/Player_Camera")
@onready var villager_panel_container = $Stat_Container
@onready var page_navigation = $Page_Container
@onready var jobs = Global.JOB

@export var villagers_per_page = 3
var villagers = []
var current_page = 0
var pages = []
const villager_display_prefab = preload("res://NPC/Scenes/indiv_stat.tscn")
var selected_villager = null  # Store the currently selected villager

func _ready():
	villagers = get_tree().get_nodes_in_group("VILLAGER")
	_create_pages()
	_show_page(current_page)
	_connect_navigation_buttons()
	_connect_villagers(villagers)
	
func _connect_villagers(villagers):
	for villager in villagers:
		villager.connect("stat_changed",update_selected_villager_display)

func _create_pages():
	# Clear existing pages
	for page in pages:
		page.queue_free()
	pages.clear()
	villager_panel_container.get_children().map(func(node): node.queue_free())

	var page_count = ceil(float(villagers.size()) / villagers_per_page)
	for i in range(page_count):
		var new_page = VBoxContainer.new()
		new_page.name = "Page" + str(i)
		new_page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		new_page.size_flags_vertical = Control.SIZE_EXPAND_FILL
		new_page.hide()
		villager_panel_container.add_child(new_page)
		pages.append(new_page)

		# Add villagers to the page
		var start_index = i * villagers_per_page
		var end_index = min((i + 1) * villagers_per_page, villagers.size())
		for j in range(start_index, end_index):
			var villager = villagers[j]
			var villager_display = villager_display_prefab.instantiate()
			# Set the data
			for job_name in jobs.keys():
				if jobs[job_name] == villager.job:
					villager_display.get_node("LabelContainer/JobLabel").text = "Job: " + str(job_name).to_lower().capitalize()
			villager_display.get_node("LabelContainer/HungerLabel").text = "Hunger: " + str(villager.hunger)
			villager_display.get_node("LabelContainer/AgeLabel").text = "Age: " + str(villager.age)
			# Get the LineEdit from the instantiated scene
			var name_input = villager_display.get_node("LabelContainer/NameInput") 
			name_input.text = villager.villager_name
			name_input.connect("text_changed", _on_name_changed.bind(villager))
			name_input.connect("focus_exited", _on_name_edit_finished.bind(villager)) 
			villager_display.villager_node = villager

			# Make the display clickable
			var button = Button.new()
			var empty_style = StyleBoxEmpty.new()
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.size_flags_vertical = Control.SIZE_EXPAND_FILL
			button.set("custom_styles/focus", empty_style)
			button.set("custom_styles/normal", empty_style)
			button.set("custom_styles/hover", empty_style)
			button.set("custom_styles/pressed", empty_style)
			button.flat = true
			button.connect("pressed", _on_villager_display_clicked.bind(villager_display))
			villager_display.add_child(button)
			new_page.add_child(villager_display)

	#create next and previous buttons
	if page_count > 1:
		_create_navigation_buttons(page_count)
	else:
		page_navigation.hide()

func _show_page(page_index):
	if page_index >= 0 and page_index < pages.size():
		for page in pages:
			page.hide()
		pages[page_index].show()
		current_page = page_index

		if is_instance_valid(page_navigation.get_node("PreviousButton")):
			page_navigation.get_node("PreviousButton").disabled = (current_page == 0)
		if is_instance_valid(page_navigation.get_node("NextButton")):
			page_navigation.get_node("NextButton").disabled = (current_page == pages.size() - 1)

func _on_villager_display_clicked(clicked_display):
	# Move camera to the villager.  Use the stored node.
	camera_2d.position = clicked_display.villager_node.position
	selected_villager = clicked_display.villager_node
	update_selected_villager_display()

func _create_navigation_buttons(page_count):
	#create the buttons only once
	if page_navigation.get_child_count() == 0:
		var previous_button = Button.new()
		previous_button.name = "PreviousButton"
		previous_button.text = "Previous"
		page_navigation.add_child(previous_button)

		var next_button = Button.new()
		next_button.name = "NextButton"
		next_button.text = "Next"
		page_navigation.add_child(next_button)

	page_navigation.show()
	_connect_navigation_buttons()

func _connect_navigation_buttons():
	if is_instance_valid(page_navigation.get_node("PreviousButton")):
		page_navigation.get_node("PreviousButton").connect("pressed", _on_previous_page)
	if is_instance_valid(page_navigation.get_node("NextButton")):
		page_navigation.get_node("NextButton").connect("pressed", _on_next_page)

func _on_previous_page():
	_show_page(current_page - 1)

func _on_next_page():
	_show_page(current_page + 1)

func _on_name_changed(new_name, villager):
	# This function is called whenever the text in the LineEdit is changed for a specific villager.
	villager.villager_name = new_name
	# print("Villager: ", villager.name, "name changed to: ", new_name)

func _on_name_edit_finished(villager):
	update_selected_villager_display()

func update_selected_villager_display():
	for page in pages:
		for child in page.get_children():
			if is_instance_valid(child.villager_node):
				for job_name in jobs.keys():
					if jobs[job_name] == child.villager_node.job:
						child.get_node("LabelContainer/JobLabel").text = "Job: " + str(job_name).to_lower().capitalize()
				child.get_node("LabelContainer/HungerLabel").text = "Hunger: " + str(child.villager_node.hunger)
				child.get_node("LabelContainer/AgeLabel").text = "Age: " + str(child.villager_node.age)
