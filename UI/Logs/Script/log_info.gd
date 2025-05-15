extends Control

@onready var scroll_container: ScrollContainer = $LogCanvas/ScrollContainer
@onready var log_container: VBoxContainer = $LogCanvas/ScrollContainer/LogContainer
@onready var log_label_settings = LabelSettings.new()

var villagers = []
var houses = []

func _ready():
	villagers = get_tree().get_nodes_in_group("VILLAGER")
	houses = get_tree().get_nodes_in_group("HOUSE")
	_connect_villagers(villagers)
	_connect_villager_birth(houses)
	log_label_settings.font_size = 10
	log_info("Game started!")
	log_info("Player joined.")
	log_info("Level loaded.")
	log_info("Game started!")
	log_info("Player joined.")
	log_info("Level loaded.")
	log_info("Game started!")
	log_info("Player joined.")
	log_info("Game started!")
	log_info("Player joined.")
	log_info("Level loaded.")
	log_info("Game started!")
	log_info("Player joined.")
	log_info("Game started!")
	log_info("Player joined.")
	log_info("Level loaded.")
	log_info("Game started!")
	log_info("Player joined.")
	log_info("Game started!")
	log_info("Player joined.")
	log_info("Level loaded.")
	log_info("Game started!")
	log_info("Player joined.")
	log_info("Game started!")
	log_info("Player joined.")
	
func _connect_villagers(villagers):
	for villager in villagers:
		villager.disconnect("villager_died",log_info)
		villager.connect("villager_died",log_info)

func _connect_villager_birth(houses):
	for house in houses:
		house.disconnect("villager_birthed",log_info)
		house.connect("villager_birthed",log_info)

func log_info(message: String):
	var log_label = Label.new()
	log_label.text = message
	log_label.label_settings = log_label_settings
	log_container.add_child(log_label)
	scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value 
