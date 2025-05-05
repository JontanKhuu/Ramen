extends Control

const TRADE_ROW = preload("res://UI/Trading/traderow.tscn")

@onready var vbox : VBoxContainer = %VBoxContainer
@onready var changeArrow: Sprite2D = %ChangeArrow
@onready var changeLabel: Label = $ChangeArrow/ChangeLabel

var initCoins : int
var change : int

func _process(delta: float) -> void:
	if !visible:
		return
	change = Global.inventory_dict[Global.RESOURCES_TRACKED.COINS] - initCoins
	changeLabel.text = str(change)
	
	if change > 0:
		changeArrow.flip_h = false
		changeArrow.modulate.r8 = 0
		changeArrow.modulate.g8 = 158
		changeArrow.modulate.b8 = 0
	elif change < 0:
		changeArrow.flip_h = true
		changeArrow.modulate.r8 = 255
		changeArrow.modulate.g8 = 0
		changeArrow.modulate.b8 = 0
	

func _on_visibility_changed() -> void:
	await get_tree().create_timer(.01).timeout
	for child in vbox.get_children():
		child.queue_free()
	
	initCoins = Global.inventory_dict[Global.RESOURCES_TRACKED.COINS]
	for i in Global.RESOURCES_TRACKED.size():
		if i == Global.RESOURCES_TRACKED.HOMES:
			continue
		if i == Global.RESOURCES_TRACKED.COINS or i == 0:
			continue
		var tradeRow = TRADE_ROW.instantiate()
		tradeRow.resource = i
		vbox.add_child(tradeRow)


func _on_button_pressed() -> void:
	visible = false
