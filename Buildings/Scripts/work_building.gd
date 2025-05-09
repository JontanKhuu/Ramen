extends StaticBody2D
class_name Workplace

@export var slot1 : Villager
@export var slot2 : Villager
@export var type : Global.WORKPLACE
@export var has_worker : bool
@export var has_resoures : bool
@export var is_full : bool
@export var storage : Dictionary
@export var max_storage : int
@export var cost : int
@export var cost2 : int
@export var productAmount : int
@export var prereq : Global.RESOURCES_TRACKED
@export var prereq2 : Global.RESOURCES_TRACKED
@export var product : Global.RESOURCES_TRACKED
@export var product2 : Global.RESOURCES_TRACKED
@export var need : Global.RESOURCES_TRACKED

@onready var sprite: Sprite2D = $Sprite2D
@onready var prodTimer: Timer = $ProductionTimer
@onready var entrance: Node2D = $Entrance

var prereq_amt : int
var job : Global.JOB = Global.JOB.NONE
var prereq2_amt : int
var prereq_max : int
var product_max : int 
func _ready() -> void:
	storage = Global.building_inventory_dict.duplicate(false)
	set_up_workplace()
	Global.update_job_limits()
	
func _process(delta: float) -> void:
	print(slot1)
	_handle_slots()
	_handle_hauling()
	
	has_resoures = check_if_stocked()
	is_full = true if storage[product] >= max_storage else false
	# has_worker is done by npc
	if has_worker and has_resoures and !is_full:
		prodTimer.paused = false
	else:
		prodTimer.paused = true
func _handle_hauling() -> void:
	if !slot1:
		return
	if has_resoures:
		slot1.is_gathering = false
		return
	slot1.is_gathering = true
	
func _handle_slots() -> void:
	# if villagers dead or changed jobs
	if !is_instance_valid(slot1) or slot1.workplace != self:
		slot1 = null
	if !is_instance_valid(slot2) or slot2.workplace != self:
		slot2 = null
	
	# find villagers according to workplace
	var workers = get_tree().get_nodes_in_group("VILLAGER")
	workers = workers.filter(func(element): return element.job == job)
	for w : Villager in workers:
		if w.workplace != null:
			continue
		if slot1 == null:
			slot1 = w
			w.workplace = self
		elif slot2 == null:
			w.workplace = self
			slot2 = w

func set_up_workplace() -> void:
	match type:
		Global.WORKPLACE.HUNT:
			# switch sprite
			sprite.frame = 0
			job = Global.JOB.HUNTER
			product = Global.RESOURCES_TRACKED.HIDES
			product2 = Global.RESOURCES_TRACKED.VENISON
		Global.WORKPLACE.CLOTH:
			job = Global.JOB.TANNER
			sprite.frame = 1
			prodTimer.wait_time = 3
			cost = 1
			productAmount = 1
			prereq = Global.RESOURCES_TRACKED.HIDES
			product = Global.RESOURCES_TRACKED.CLOTHES
		Global.WORKPLACE.MINE:
			job = Global.JOB.MINER
			sprite.frame = 1 # 2
			prodTimer.wait_time = 1
			cost = 0
			product = Global.RESOURCES_TRACKED.STONE
		Global.WORKPLACE.COOKERY:
			job = Global.JOB.COOK
			sprite.frame = 1 # 3
			prodTimer.wait_time = 2
			cost = 1
			productAmount = 1
			prereq = Global.RESOURCES_TRACKED.VENISON
			product = Global.RESOURCES_TRACKED.STEAK
	set_limits()

func _on_production_timer_timeout() -> void:
	if type == Global.WORKPLACE.HUNT:
		return
	storage[product] += productAmount
	storage[prereq] -= cost
	Global.update_storages()

func set_limits() -> void:
	if prereq == Global.RESOURCES_TRACKED.NONE:
		prereq_max = 0
		product_max = 24
		return
	# Assume prereq now has value
	if prereq2 == Global.RESOURCES_TRACKED.NONE:
		prereq_max = 12
		product_max = 12
		return
	if product2 == Global.RESOURCES_TRACKED.NONE:
		prereq_max = 6
		product_max = 12
		return
	# Assume prereq 2 now has value
	prereq_max = 6
	product_max = 6
	%demOne.max_value = prereq_max
	%demTwo.max_value = prereq_max
	return

func check_if_stocked() -> bool:
	if storage[prereq] >= cost and storage[prereq2] >= cost2:
		return true
	return false
	
func has_food() -> Array:
	var availFood : Array = []
	for food in Global.foods:
		if storage[Global.naming_dict.find_key(food)] > 0:
			availFood.append(Global.naming_dict.find_key(food))
	return availFood


func _on_utility_ai_agent_top_score_action_changed(top_action_id: Variant) -> void:
	print(top_action_id)
	match top_action_id:
		"none":
			need = Global.RESOURCES_TRACKED.NONE
		"prereq1":
			need = prereq
		"prereq2":
			need = prereq2
