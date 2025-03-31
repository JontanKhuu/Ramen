extends Control

func _on_gui_input(event: InputEvent) -> void:
	get_parent().close_calendar()
