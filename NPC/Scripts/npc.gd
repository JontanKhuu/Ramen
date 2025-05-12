extends CharacterBody2D
class_name Villager

const kidSprite = preload("res://NPC/Assets/VillagerKidMale.png")
const manSprite = preload("res://NPC/Assets/VillagerMale.png")

enum LOOKING_FOR{
	NONE, WOOD, BUILDING, BED, PLANT, HARVEST, PICKDROPS, STORAGE, HUNT, 
	TAN, HAUL, FILL, MINE, COOK, EAT, SMELT, FORGE
}

@export var speed := 100
@export var age : int = 6
@export var age_limit : int = 25
@export var is_child : bool

@export var task : LOOKING_FOR
@export var job : Global.JOB
@export var state : Global.VILLAGER_STATE
@export var bed : Node2D
@export var workplace : Workplace
@export var hunger : int = 1

@onready var wander_timer: Timer = %WanderTimer
@onready var tiles : BuildMap = get_node("/root/World/TileMap")
@onready var grassTiles : TileMapLayer = tiles.get_child(0)
@onready var treeTiles : TileMapLayer = tiles.get_child(1)
@onready var nav: NavigationAgent2D = %NavigationAgent2D
@onready var utilAI: UtilityAiAgent = $UtilityAiAgent
@onready var resource_hold: Sprite2D = %ResourceHold
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var birthTimer : Timer = $BirthTimer
var _target

var aStar : AStarGrid2D
var path_points : Array

var is_gathering : bool = false
func _ready() -> void:
	aStar = tiles.aStar

func _process(delta: float) -> void:
	print(velocity)
	if birthTimer.time_left > 0:
		age = 1
		day_passed()
		z_index = 10
		velocity = Vector2(0,200)
		move_and_slide()
		return
	
	_handle_target(delta)
	
	if is_child:
		return
	if velocity != Vector2.ZERO:
		anim.play("walk")
	elif nav.is_navigation_finished():
		anim.play("idle")
func _handle_target(delta: float):
	visible = true
	# if no target, find one according to job
	if !_target:
		_target = null
		velocity = Vector2.ZERO
		match task:
			LOOKING_FOR.WOOD:
				find_wood()
			LOOKING_FOR.BUILDING:
				find_building()
			LOOKING_FOR.BED:
				find_bed()
			LOOKING_FOR.PLANT:
				find_plant()
			LOOKING_FOR.HARVEST:
				find_harvest()
			LOOKING_FOR.PICKDROPS:
				_on_utility_ai_agent_top_score_action_changed(utilAI._current_top_action)
			LOOKING_FOR.STORAGE:
				find_storage()
			LOOKING_FOR.HUNT:
				find_hunt()
			LOOKING_FOR.TAN:
				find_workplace(Global.WORKPLACE.CLOTH)
			LOOKING_FOR.HAUL:
				if workplace and currentDrop == null:
					haul()
				else:
					_on_utility_ai_agent_top_score_action_changed(utilAI._current_top_action)
			LOOKING_FOR.FILL:
				if workplace and currentDrop == null:
					find_fill(workplace)
				else:
					_on_utility_ai_agent_top_score_action_changed(utilAI._current_top_action)
			LOOKING_FOR.MINE:
				find_workplace(Global.WORKPLACE.MINE)
			LOOKING_FOR.COOK:
				find_workplace(Global.WORKPLACE.COOKERY)
			LOOKING_FOR.EAT:
				wander_timer.stop()
				find_eat()
			LOOKING_FOR.SMELT:
				find_workplace(Global.WORKPLACE.SMELTER)
			LOOKING_FOR.FORGE:
				find_workplace(Global.WORKPLACE.FORGE)
		return
	
	_handle_navigation_path()
	
	# if at position of target, do action according to task
	var to_target = self.global_position.distance_to(_target)
	match task:
		LOOKING_FOR.NONE:
			if to_target < 5 or nav.is_navigation_finished():
				wander_timer.start()
				_target = null
				return
		LOOKING_FOR.WOOD:
			if to_target < 10:
				cut_wood()
				return
		LOOKING_FOR.BUILDING:
			if to_target < 8:
				_target = null
				return
		LOOKING_FOR.BED :
			if to_target < 5 or nav.is_navigation_finished():
				visible = false
				return
		LOOKING_FOR.PLANT:
			if to_target < 2:
				plant_seed()
				return
		LOOKING_FOR.HARVEST:
			if to_target < 2:
				harvest_plant()
				return
		LOOKING_FOR.PICKDROPS:
			if to_target < 10:
				pick_up_resource()
				return
		LOOKING_FOR.STORAGE:
			if to_target < 10:
				store_resource(currentDrop.type,currentDrop.amount)
				return
		LOOKING_FOR.HUNT:
			if to_target < 8:
				hunt()
				return
			else:
				find_hunt()
		LOOKING_FOR.TAN:
			if normal_production(to_target):
				return
		LOOKING_FOR.HAUL:
			if to_target < 5 and currentDrop == null:
				haul()
				return
			elif to_target < 5 and _target != workplace.entrance.global_position:
				store_resource(currentDrop.type,currentDrop.amount)
				return
		LOOKING_FOR.FILL:
			if to_target < 5 and currentDrop == null:
				haul_fill()
				return
			elif to_target < 5:
				storageBuilding = workplace
				store_resource(currentDrop.type,currentDrop.amount)
				return
		LOOKING_FOR.MINE:
			if normal_production(to_target):
				return
		LOOKING_FOR.COOK:
			if normal_production(to_target):
				return
		LOOKING_FOR.EAT:
			if to_target < 5:
				eat()
				return
		LOOKING_FOR.SMELT:
			if normal_production(to_target):
				return
		LOOKING_FOR.FORGE:
			if normal_production(to_target):
				return
	
	move_to(self.global_position.direction_to(nav.get_next_path_position()), delta)

func normal_production(dis) -> bool:
	if dis < 8:
		visible = false
		workplace.has_worker = true
		return true
	else:
		workplace.has_worker = false
	return false

# Movement 

func move_to(direction, _delta):
	if direction.x > 0:
		$Flip.scale.x = -1
	else:
		$Flip.scale.x = 1
		
	var new_velocity = direction * speed
	velocity = new_velocity
	
	if nav.avoidance_enabled:
		nav.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
		
	move_and_slide()
	
# weird navigation pathfinding against other npcs stuff
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

func _handle_navigation_path() -> void:
	# go through each path point that astar provides to target
	if nav.is_navigation_finished():
		path_points.pop_front()
	if path_points.is_empty():
		var position_id = grassTiles.local_to_map(global_position)
		var target_id = grassTiles.local_to_map(_target)
		path_points = aStar.get_id_path(position_id,target_id,true)
		return
	
	nav.target_position = grassTiles.map_to_local(path_points.front())
	pass

# Idling
func wander():
	# wander a certain distance from current point
	var WAN_DIS = 60
	var start_pos = global_position
	var des_pos = start_pos + Vector2(randf_range(-WAN_DIS,WAN_DIS),randf_range(-WAN_DIS,WAN_DIS))
	_target = des_pos

func _on_wander_timer_timeout() -> void:
	wander()

# Cutting woooooooooood
func find_wood() -> void:
	if find_drops(Global.RESOURCES_TRACKED.WOOD,Global.RESOURCES_TRACKED.STONE):
		find_drops(Global.RESOURCES_TRACKED.WOOD,Global.RESOURCES_TRACKED.STONE)
		return
	# add tree and stone tiles
	var treesPos = treeTiles.get_used_cells_by_id(0,Vector2(0,0),1).map(treeTiles.map_to_local)
	treesPos.append_array(treeTiles.get_used_cells_by_id(1,Vector2(0,0),1).map(treeTiles.map_to_local))
	
	if treesPos.is_empty():
		return
	# find closest tree
	var closest = treesPos.front()
	for tree in treesPos:
		var dis_to_close = global_position.distance_to(closest)
		var dis_to_curTree = global_position.distance_to(tree)
		
		if dis_to_curTree < dis_to_close:
			closest = tree
	_target = closest

func cut_wood() -> void:
	var tree_map_pos = treeTiles.local_to_map(_target)
	var tree_data = treeTiles.get_cell_tile_data(tree_map_pos)
	var type = tree_data.get_custom_data("Type")
	var amount : int = tree_data.get_custom_data("Amount")
	for i in range(amount):
		tiles.spawn_resource(tree_map_pos,Global.naming_dict.find_key(type))
	
	treeTiles.set_cell(tree_map_pos,0)
	grassTiles.set_cell(tree_map_pos,0,Vector2i(0,1))
	
	_target = null
	pass

# Building stooooooof
func find_building() -> void:
	if Global.build_queue.size() <= 0:
		return
	var building = Global.build_queue[0]
	_target = building.east.global_position

# Sleep
func find_bed() -> void:
	if !bed:
		_target = null
		return
	_target = bed.global_position

# Planting
var plant : Crop

func find_plant() -> void:
	if find_drops(Global.RESOURCES_TRACKED.BERRIES,Global.RESOURCES_TRACKED.NONE):
		find_drops(Global.RESOURCES_TRACKED.BERRIES,Global.RESOURCES_TRACKED.NONE)
		return
	var crops = get_tree().get_nodes_in_group("CROP")
	# filter for already planted crops
	crops = crops.filter(func(element):return !element.planted) 
	if crops.size() <= 0:
		return
	
	var closest = find_closest(crops)
	_target = closest.global_position
	plant = closest

func plant_seed() -> void:
	if !plant:
		_target = null
		plant = null
		return
	plant.planted = true
	# plant.sprite.frame += 1
	_target = null
	plant = null

# Harvesting
func find_harvest() -> void:
	if find_drops(Global.RESOURCES_TRACKED.BERRIES,Global.RESOURCES_TRACKED.NONE):
		find_drops(Global.RESOURCES_TRACKED.BERRIES,Global.RESOURCES_TRACKED.NONE)
		return
	var crops = get_tree().get_nodes_in_group("CROP")
	# filter for only fully grown crops
	crops = crops.filter(func(element): return element.grown)
	if crops.size() <= 0:
		_target = null
		return
	
	var closest = find_closest(crops)
	_target = closest.global_position
	plant = closest

func harvest_plant() -> void:
	if !plant:
		return
	for i in range(plant.amount):
		var pos = grassTiles.local_to_map(plant.global_position)
		tiles.spawn_resource(pos,Global.RESOURCES_TRACKED.BERRIES)
	plant.time = 0.0
	plant.planted = false
	plant.grown = false
	_target = null
	plant = null

# Pick up and transport resources          
var currentDrop : Drops
var storageBuilding
func find_drops(type : Global.RESOURCES_TRACKED, type2 : Global.RESOURCES_TRACKED) -> bool:
	# check if there is drops
	var preDrops = get_tree().get_nodes_in_group("DROPS")
	var drops = preDrops.filter(func(element): return type == element.type)
	if type2 != Global.RESOURCES_TRACKED.NONE:
		drops.append_array(preDrops.filter(func(element): return element.type == type2))
	if drops.is_empty():
		return false
	
	# find closest drop
	var closest = find_closest(drops)
	_target = closest.global_position
	currentDrop = closest
	task = LOOKING_FOR.PICKDROPS
	return true
func pick_up_resource():
	resource_hold.visible = true
	resource_hold.frame = currentDrop.frame
	currentDrop.visible = false
	# change later to be on top of head
	task = LOOKING_FOR.STORAGE
	_target = null

func find_storage():
	# find closest storgae otherwise just drop at tent
	var storages = get_tree().get_nodes_in_group("STORAGE")
	if workplace != null and task != LOOKING_FOR.HAUL:
		storages.append(workplace)
	if storages.is_empty():
		_target = get_tree().get_first_node_in_group("TENT").entrance.global_position
		storageBuilding = get_tree().get_first_node_in_group("TENT")
		return
	var closest = find_closest(storages)
	if closest is Workplace:
		_target = closest.entrance.global_position
	else:
		_target = closest.bed.global_position
	storageBuilding = closest
	#
func store_resource(type : Global.RESOURCES_TRACKED,amt : int):
	resource_hold.visible = false
	currentDrop.queue_free()
	storageBuilding.storage[type] += amt
	Global.update_storages()
	_on_utility_ai_agent_top_score_action_changed(utilAI._current_top_action)
	
# Hunting
var animal
func find_hunt():
	var camps = get_tree().get_nodes_in_group("WORKPLACE")
	camps = camps.filter(func(element):return element.type == Global.WORKPLACE.HUNT)
	workplace = find_closest(camps)
	if find_drops(Global.RESOURCES_TRACKED.VENISON,Global.RESOURCES_TRACKED.HIDES):
		find_drops(Global.RESOURCES_TRACKED.VENISON,Global.RESOURCES_TRACKED.HIDES)
		return
		
	var deer = get_tree().get_nodes_in_group("DEERMEN")
	if deer.is_empty() or workplace.is_full:
		task = LOOKING_FOR.HAUL
		_target = workplace.entrance.global_position
		return
	var closest = find_closest(deer)
	animal = closest
	_target = closest.global_position

func hunt():
	var pos = grassTiles.local_to_map(animal.global_position)
	for i in range(animal.meat_amount):
		tiles.spawn_resource(pos,Global.RESOURCES_TRACKED.VENISON)
	for i in range(animal.leather_amount):
		tiles.spawn_resource(pos,Global.RESOURCES_TRACKED.HIDES)
	animal.queue_free()
	_target = null
	
# Tan
func find_workplace(worktype : Global.WORKPLACE) -> void:
	if workplace == null :
		return
	
	_target = workplace.entrance.global_position

# haul (emptying work storages)
func haul() -> void:
	if workplace == null:
		_on_utility_ai_agent_top_score_action_changed(utilAI._current_top_action)
		return
	if workplace.storage[workplace.product] <= 0 and workplace.storage[workplace.product2] <= 0 :
		return
	
	currentDrop = Drops.new()
	currentDrop.visible = false
	if workplace.storage[workplace.product] > 0:
		currentDrop.type = workplace.product 
	else:
		currentDrop.type = workplace.product2
	currentDrop.amount = 1
	resource_hold.visible = true
	resource_hold.frame = currentDrop.frame
	
	workplace.storage[currentDrop.type] -= currentDrop.amount
	Global.update_storages()
	
	find_storage()

# fill work storages
func find_fill(wp : Workplace) -> void:
	if wp == null:
		return
	var storages = get_tree().get_nodes_in_group("STORAGE")
	storages.append(get_tree().get_first_node_in_group("TENT"))
	storages.append_array(get_tree().get_nodes_in_group("WORKPLACE"))
	
	storages = storages.filter(has_resource)
	storageBuilding = find_closest(storages)
	if storageBuilding == null:
		return
	if storageBuilding is Workplace or storageBuilding is Tent:
		_target = storageBuilding.entrance.global_position
	else:
		_target = storageBuilding.bed.global_position
func has_resource(node):
	if node == workplace:
		return false
	return node.storage[workplace.need] > 0

func haul_fill() -> void:
	currentDrop = Drops.new()
	currentDrop.visible = false
	currentDrop.type = workplace.need
	currentDrop.amount = 1
	resource_hold.visible = true
	resource_hold.frame = currentDrop.frame
	
	_target = workplace.entrance.global_position
	storageBuilding.storage[currentDrop.type] -= currentDrop.amount
	Global.update_storages()
	
var foods : Array = []
func find_eat() -> void:
	var cookeries = get_tree().get_nodes_in_group("WORKPLACE")
	cookeries = cookeries.filter(func(element):return element.type == Global.WORKPLACE.COOKERY)
	var eatSpots = get_tree().get_nodes_in_group("STORAGE")
	eatSpots.append_array(get_tree().get_nodes_in_group("TENT"))
	eatSpots.append_array(cookeries)
	eatSpots = eatSpots.filter(func(element):return !element.has_food().is_empty())
	
	storageBuilding = find_closest(eatSpots)
	if !storageBuilding:
		hunger -= 1
		_on_utility_ai_agent_top_score_action_changed(utilAI._current_top_action)
		return
	if storageBuilding is Tent or storageBuilding is Workplace:
		_target = storageBuilding.entrance.global_position
	else:
		_target = storageBuilding.bed.global_position
	foods = storageBuilding.has_food()
	
func eat() -> void:
	var randi = randi() % foods.size()
	storageBuilding.storage[foods[randi]] -= 1
	storageBuilding = null
	Global.update_storages()
	_on_utility_ai_agent_top_score_action_changed(utilAI._current_top_action)

# Utility AI
func find_closest(nodeArray : Array):
	if nodeArray.is_empty():
		_target = null
		return null
	var closest = nodeArray[0]
	for node in nodeArray:
		var dis_to_close = global_position.distance_to(closest.global_position)
		var dis_to_cur = global_position.distance_to(node.global_position)
		
		if dis_to_cur < dis_to_close:
			closest = node
	return closest

func _on_utility_ai_agent_top_score_action_changed(top_action_id) -> void:
	_target = null
	wander_timer.stop()
	print("Action changed: %s" % top_action_id)
	match top_action_id:
		"idle":
			task = LOOKING_FOR.NONE
			wander()
		"cut_wood":
			task = LOOKING_FOR.WOOD
		"build":
			task = LOOKING_FOR.BUILDING
		"sleep":
			task = LOOKING_FOR.BED
		"plant":
			task = LOOKING_FOR.PLANT
		"harvest":
			task = LOOKING_FOR.HARVEST
		"hunt":
			task = LOOKING_FOR.HUNT
		"tan":
			task = LOOKING_FOR.TAN
		"fill":
			task = LOOKING_FOR.FILL
		"mine":
			task = LOOKING_FOR.MINE
		"cook":
			task = LOOKING_FOR.COOK
		"smelt":
			task = LOOKING_FOR.SMELT
		"forge":
			task = LOOKING_FOR.FORGE
		

# Days
func day_passed() -> void:
	if hunger <= -2:
		queue_free()
	age += 1
	if age < 6:
		is_child = true
		%Sprite2D.texture = kidSprite
		%Sprite2D.hframes = 1
	else:
		is_child = false
		job = Global.JOB.NONE
		%Sprite2D.hframes = 6
		%Sprite2D.texture = manSprite
		# is adult and work
	if age > 21:
		var diff = age_limit - age
		var rand : int = randi() % 10 + 1
		if rand >= 1 + diff:
			queue_free()


func _on_birth_timer_timeout() -> void:
	z_index = 1
