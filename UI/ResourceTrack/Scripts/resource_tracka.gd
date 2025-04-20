extends HBoxContainer

@export var trackedResource : Global.RESOURCES_TRACKED

@onready var label: Label = %Label
@onready var icon: Sprite2D = %Icon

func _process(delta: float) -> void:
	label.text = str(int(Global.inventory_dict[trackedResource]))
	
	match trackedResource:
		Global.RESOURCES_TRACKED.WOOD:
			icon.frame = 5
		Global.RESOURCES_TRACKED.FOOD:
			icon.frame = 6
		Global.RESOURCES_TRACKED.COINS:
			icon.frame = 14
