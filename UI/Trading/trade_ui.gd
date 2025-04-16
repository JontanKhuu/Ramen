extends Control

var initCoins : int
var change : int

func _process(delta: float) -> void:
	if !visible:
		return
	change = Global.inventory_dict[Global.RESOURCES_TRACKED.COINS] - initCoins
	

func _on_visibility_changed() -> void:
	initCoins = Global.inventory_dict[Global.RESOURCES_TRACKED.COINS]
