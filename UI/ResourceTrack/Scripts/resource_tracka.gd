extends HBoxContainer

@export var trackedResource : Resources.RESOURCES_TRACKED
@onready var label: Label = %Label

func _process(delta: float) -> void:
	match trackedResource:
		0:
			label.text = str(Global.inventory_dict[trackedResource])
			
