extends SpinBox
class_name JobBox

@export var type : Global.JOB

func _process(delta: float) -> void:
	if value == max_value and value == min_value:
		editable = true
		editable = false
	else:
		editable = true
