extends Control

@onready var item_sprite: Sprite2D = $ItemSprite
@onready var item_count_label: Label = $ItemCount
@onready var check_item_button: Button = $CheckItem

@export var item_name: String
@export var item_data: Dictionary
@export var item_description_scene: PackedScene
@export var item_description: String = ""

signal item_used

func _ready():
	if item_data:
		if item_sprite:
			item_sprite.texture = load(item_data.get("sprite_path", ""))
		if item_count_label:
			item_count_label.text = str(item_data.get("total_items", 0))
		if check_item_button:
			check_item_button.connect("pressed", _on_check_item_pressed)
	else:
		printerr("Error: Item data not set for ItemCell.")

func _on_check_item_pressed():
	_close_existing_description() 
	if item_description_scene:
		var item_description_instance = item_description_scene.instantiate()
		var inventory_node = get_parent().get_parent().get_parent()
		var IDContainer = inventory_node.get_node("ItemDescriptionContainer")
		IDContainer.add_child(item_description_instance)
		item_description_instance.size_flags_horizontal = Control.SIZE_EXPAND_FILL 
		item_description_instance.size_flags_vertical = Control.SIZE_EXPAND_FILL 

		# Find and populate the ItemDescription nodes
		var description_panel = item_description_instance.get_node("DescriptionPanel")
		if description_panel:
			var full_container = description_panel.get_node("FullContainer")
			if full_container:
				var visuals_container = full_container.get_node("VisualsContainer")
				var description_container = full_container.get_node("DescriptionContainer")

				if visuals_container:
					var sprite_container = visuals_container.get_node("SpriteContainer")
					var prompt_container = visuals_container.get_node("PromptContainer") #remains

					if sprite_container:
						var item_sprite_display = sprite_container.get_node("ItemSprite")
						if item_sprite_display is Sprite2D and item_data.has("sprite_path"):
							item_sprite_display.texture = load(item_data["sprite_path"])
							# Calculate scaling to fit the container
							var sprite_size = item_sprite_display.texture.get_size()
							
							var scale_x = 82 / sprite_size.x
							var scale_y = 80 / sprite_size.y

							# Use the smaller scale to maintain aspect ratio
							var scale = min(scale_x, scale_y)
							item_sprite_display.scale = Vector2(scale, scale)

						elif sprite_container:
							printerr("Error: Sprite2D or sprite_path not found in ItemDescription.")


					if prompt_container:
						var use_button = prompt_container.get_node("UseItem")
						var close_button = prompt_container.get_node("CloseMenu")
						
						if use_button is Button:
							use_button.connect("pressed", _on_item_use.bind())
						
						if close_button is Button:
							close_button.connect("pressed", _on_close_menu_pressed.bind(item_description_instance))

				if description_container:
					var description_label = description_container.get_node("Description")
					if description_label is RichTextLabel:
						description_label.text = item_description # Use the exported variable
					else:
						printerr("Error: RichTextLabel not found in ItemDescription.")
						
func _on_item_use():
	if int(item_count_label.text) >= 0:
		item_count_label.text = str(int(item_count_label.text) - 1)
		item_used.emit()
	else:
		print("Not enough items")

func _on_close_menu_pressed(item_description_instance: Control):
	if is_instance_valid(item_description_instance):
		item_description_instance.queue_free()
		

func _close_existing_description():
	var inventory_node = get_parent().get_parent().get_parent()
	var IDContainer = inventory_node.get_node("ItemDescriptionContainer")
	for child in IDContainer.get_children():
		child.queue_free()
		
		
