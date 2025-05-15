extends Control

@export var ItemCell: PackedScene
@export var ItemDescription: PackedScene

@onready var IDContainer = get_node("ItemDescriptionContainer")

var inventory = {
	"Usable Item 1": {
		"total_items": 11,
		"sprite_path": "res://UI/Inventory/Assets/Test_Item.png",
		"description": "this is a test itemthis is a test itemthis is a test itemthis is a test itemthis is a test itemthis is a test itemthis is a test itemthis is a test itemthis is a test itemthis is a test item",
		"action": Callable(self, "item_1_function")
	},
	"Test Item 2": {
		"total_items": 2,
		"sprite_path": "res://UI/Inventory/Assets/Test_Item.png",
		"description": "this is a test item that can be used",
		"action": Callable(self, "item_2_function")
	},
	"Test Item 3": {
		"total_items": 5,
		"sprite_path": "res://UI/Inventory/Assets/Test_Item.png",
		"description": "this is a test item that can be used",
		"action": Callable(self, "item_3_function")
	},
}

func _ready():
	_populate_inventory()

func _populate_inventory():
	var grid_container = get_node("NinePatchRect/GridContainer")
	if not grid_container:
		printerr("Error: GridContainer not found in the scene tree.")
		return

	# Clear existing items in the grid container
	for child in grid_container.get_children():
		child.queue_free()

	for item_name in inventory.keys():
		var item_data = inventory[item_name]
		var item_cell_instance = ItemCell.instantiate()
		grid_container.add_child(item_cell_instance)

		# Access and update the nodes within the ItemCell instance
		var item_sprite = item_cell_instance.get_node("ItemSprite")
		var item_count_label = item_cell_instance.get_node("ItemCount")
		var check_item_button = item_cell_instance.get_node("CheckItem")

		if item_sprite is Sprite2D:
			item_sprite.texture = load(item_data["sprite_path"])
		else:
			printerr("Error: ItemSprite not found in ItemCell.")

		if item_count_label is Label:
			item_count_label.text = str(item_data["total_items"])
		else:
			printerr("Error: ItemCount not found in ItemCell.")

		# Pass relevant data to the ItemCell script
		if item_cell_instance:
			item_cell_instance.item_name = item_name
			item_cell_instance.item_data = item_data
			item_cell_instance.item_description = item_data.get("description", "")
			var action = item_data.get("action")
			if action is Callable:
				item_cell_instance.connect("item_used", inventory[item_name]["action"])
			else:
				printerr("Item action is not a Callable")
		else:
			printerr("Warning: ItemCell instance does not have an attached script.")

func update_inventory(new_inventory: Dictionary):
	inventory = Global.player_inventory
	_populate_inventory()
	
func clear_idContainer():
	for child in IDContainer.get_children():
		child.queue_free()

func decrease_item_count(inventory: Dictionary, item_name: String):
		Global.player_inventory[item_name]["total_items"] -= 1
		print(Global.player_inventory[item_name]["total_items"])
		if Global.player_inventory[item_name]["total_items"] == 0:
			clear_idContainer()
			inventory.erase("Usable Item 1")
			update_inventory(inventory)

# Example item functions (these are still here but not directly used by Inventory)
func item_1_function():
	print("Used Usable Item 1")
	if inventory["Usable Item 1"]["total_items"] == 0:
		clear_idContainer()
		inventory.erase("Usable Item 1")
		update_inventory(inventory)
	else:
		decrease_item_count(inventory, "Usable Item 1")

func item_2_function():
	print("Used Usable Item 2")
	if inventory["Test Item 2"]["total_items"] == 0:
		clear_idContainer()
		inventory.erase("Test Item 2")
		update_inventory(inventory)
	else:
		inventory["Test Item 2"]["total_items"] -= 1
		
func item_3_function():
	print("Used Usable Item 3")
	if inventory["Test Item 3"]["total_items"] == 0:
		clear_idContainer()
		inventory.erase("Test Item 3")
		update_inventory(inventory)
	else:
		inventory["Test Item 3"]["total_items"] -= 1
