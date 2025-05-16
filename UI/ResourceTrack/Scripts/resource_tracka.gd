extends HBoxContainer

@export var trackedResource : Global.RESOURCES_TRACKED
@export var amount : int

@onready var label: Label = %Label
@onready var icon: Sprite2D = %Icon

func _ready() -> void:
	match trackedResource:
		Global.RESOURCES_TRACKED.WOOD:
			icon.frame = 5
		Global.RESOURCES_TRACKED.BERRIES:
			icon.frame = 19
		Global.RESOURCES_TRACKED.COINS:
			icon.frame = 14
		Global.RESOURCES_TRACKED.STONE:
			icon.frame = 8
		Global.RESOURCES_TRACKED.VENISON:
			icon.frame = 20
		Global.RESOURCES_TRACKED.HIDES:
			icon.frame = 21
		Global.RESOURCES_TRACKED.CLOTHES:
			icon.frame = 22
			
func _process(delta: float) -> void:
	label.text = str(int(Global.inventory_dict[trackedResource]))
	amount = int(Global.inventory_dict[trackedResource])
