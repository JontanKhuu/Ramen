extends Control

@export var tribute : float = Global.tribute_payment

@onready var label: Label = %Label

var paid : bool = false



func _on_button_pressed() -> void:
	if Global.inventory_dict[Global.RESOURCES_TRACKED.COINS] < tribute:
		# lose
		pass
	else:
		paid = true
		Global.inventory_dict[Global.RESOURCES_TRACKED.COINS] -= tribute
	
	visible = false


func _on_visibility_changed() -> void:
	if paid:
		label.text = "You have paid this month's tribute, the ambassador will leave"
