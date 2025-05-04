extends CharacterBody2D
class_name Villager

enum LOOKING_FOR{
	NONE, WOOD, BUILDING, BED, PLANT, HARVEST, PICKDROPS, STORAGE, HUNT, TAN
}

@export var speed := 100

@export var task : LOOKING_FOR
@export var job : Global.JOB
@export var state : Global.VILLAGER_STATE
@export var bed : Node2D
@export var workplace : Workplace

@onready var wander_timer: Timer = %WanderTimer
@onready var tiles : BuildMap = get_node("/root/World/TileMap")
@onready var grassTiles : TileMapLayer = tiles.get_child(0)
@onready var treeTiles : TileMapLayer = tiles.get_child(1)
@onready var nav: NavigationAgent2D = %NavigationAgent2D
@onready var utilAI: UtilityAiAgent = $UtilityAiAgent

var _target

var aStar : AStarGrid2D
var path_points : Array

func _ready() -> void:
	aStar = tiles.aStar

func _process(delta: float) -> void:
	_handle_target(delta)

func _handle_target(delta: float):
	visible = true
	# if no target, find one according to job
	if !_target:
		_target = null
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
				find_tan()
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
			if to_target < 10:
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
			if to_target < 8:
				pick_up_resource()
				return
		LOOKING_FOR.STORAGE:
			if to_target < 5:
				store_resource(currentDrop.type,currentDrop.amount)
				_target = null
				return
		LOOKING_FOR.HUNT:
			if to_target < 5:
				hunt()
				return
			else:
				find_hunt()
		
	
	move_to(self.global_position.direction_to(nav.get_next_path_position()), delta)

# Movement 

func move_to(direction, _delta):
	#if direction.x > 0:
		#$Flip.scale.x = 1
		#turn right
	#else:
		# turn left
		#$Flip.scale.x = -1
	# warning-ignore:return_value_discarded
		
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
	if find_drops(Global.RESOURCES_TRACKED.FOOD,Global.RESOURCES_TRACKED.NONE):
		find_drops(Global.RESOURCES_TRACKED.FOOD,Global.RESOURCES_TRACKED.NONE)
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
	if find_drops(Global.RESOURCES_TRACKED.FOOD,Global.RESOURCES_TRACKED.NONE):
		find_drops(Global.RESOURCES_TRACKED.FOOD,Global.RESOURCES_TRACKED.NONE)
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
		tiles.spawn_resource(pos,Global.RESOURCES_TRACKED.FOOD)
	plant.time = 0.0
	plant.planted = false
	plant.grown = false
	_target = null
	plant = null

# Pick up and transport resources          
var currentDrop : Drops
func find_drops(type : Global.RESOURCES_TRACKED, type2 : Global.RESOURCES_TRACKED) -> bool:
	var preDrops = get_tree().get_nodes_in_group("DROPS")
	var drops = preDrops.filter(func(element): return type == element.type)
	if type2 != Global.RESOURCES_TRACKED.NONE:
		drops.append_array(preDrops.filter(func(element): return element.type == type2))
	if drops.is_empty():
		return false
	
	var closest = find_closest(drops)
	_target = closest.global_position
	currentDrop = closest
	task = LOOKING_FOR.PICKDROPS
	return true
func pick_up_resource():
	currentDrop.visible = false
	# change later to be on top of head
	task = LOOKING_FOR.STORAGE
	_target = null
	pass

func find_storage():
	var storages = get_tree().get_nodes_in_group("STORAGE")
	if storages.is_empty():
		_target = get_tree().get_first_node_in_group("TENT").entrance.global_position
		return
	var closest = find_closest(storages)
	_target = closest.global_position
	pass

func store_resource(type : Global.RESOURCES_TRACKED,amt : int):
	currentDrop.queue_free()
	Global.inventory_dict[type] += amt
	_on_utility_ai_agent_top_score_action_changed(utilAI._current_top_action)
	pass
	
# Hunting
var animal
func find_hunt():
	if find_drops(Global.RESOURCES_TRACKED.VENISON,Global.RESOURCES_TRACKED.HIDES):
		find_drops(Global.RESOURCES_TRACKED.VENISON,Global.RESOURCES_TRACKED.HIDES)
		return
	var deer = get_tree().get_nodes_in_group("DEERMEN")
	if deer.is_empty():
		return
	var closest = find_closest(deer)
	animal = closest
	_target = closest.global_position
	pass
func hunt():
	var pos = grassTiles.local_to_map(animal.global_position)
	for i in range(animal.meat_amount):
		tiles.spawn_resource(pos,Global.RESOURCES_TRACKED.VENISON)
	for i in range(animal.leather_amount):
		tiles.spawn_resource(pos,Global.RESOURCES_TRACKED.HIDES)
	animal.queue_free()
	_target = null
# Tan
func find_tan() -> void:
	var tans = get_tree().get_nodes_in_group("WORKPLACE")
	tans = tans.filter(func(element): return element.type == Global.WORKPLACE.CLOTH)
	var closest = find_closest(tans)
	workplace = closest
	_target = closest.global_position
	pass
# Utility AI
func find_closest(nodeArray : Array):
	var closest = nodeArray[0]
	for node in nodeArray:
		var dis_to_close = global_position.distance_to(closest.global_position)
		var dis_to_cur = global_position.distance_to(node.global_position)
		
		if dis_to_cur < dis_to_close:
			closest = node
	return closest
	pass

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
