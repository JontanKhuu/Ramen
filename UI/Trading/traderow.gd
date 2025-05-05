extends HBoxContainer

@export var resource : Global.RESOURCES_TRACKED
var resource_icon : Texture2D
var price : int
var inv : int

@onready var sell: SpinBox = $Sell

func _process(delta: float) -> void:
	price = Global.value_dict[resource]
	inv = Global.inventory_dict[resource]
	
	$Resource.text = str(Global.naming_dict[resource])
	$Price.text = str(price)
	$Inv.text = str(inv)

func _on_sell_complete_pressed() -> void:
	if sell.value > Global.inventory_dict[resource]:
		return
	Global.inventory_dict[resource] -= sell.value
	Global.inventory_dict[Global.RESOURCES_TRACKED.COINS] += sell.value * price
	sell.value = 0
