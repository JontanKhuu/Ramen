extends HBoxContainer

@export var trackedResource : Global.RESOURCES_TRACKED
@onready var label: Label = %Label

func _process(delta: float) -> void:
	match trackedResource:
		0:
			label.text = str(int(Global.inventory_dict[trackedResource]))
			
