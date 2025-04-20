extends CharacterBody2D
class_name Villager

enum LOOKING_FOR{
	NONE, WOOD, BUILDING, BED, PLANT, HARVEST
}

@export var speed := 100

@export var task : LOOKING_FOR
@export var job : Global.JOB
@export var state : Global.VILLAGER_STATE
@export var bed : Node2D

@onready var wander_timer: Timer = %WanderTimer
@onready var tiles : Node2D = get_node("/root/World/TileMap")
@onready var grassTiles : TileMapLayer = tiles.get_child(0)
@onready var treeTiles : TileMapLayer = tiles.get_child(1)
@onready var nav: NavigationAgent2D = %NavigationAgent2D

var is_moving : bool = false
var _target

func _ready() -> void:
	pass

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
			
		return
	nav.target_position = _target
	
	# if at position of target, do action according to task
	var to_target = self.global_position.distance_to(_target)
	match task:
		LOOKING_FOR.NONE:
			if to_target < 5:
				wander_timer.start()
				_target = null
				return
		LOOKING_FOR.WOOD:
			if to_target < 10:
				cut_wood()
				return
		LOOKING_FOR.BUILDING:
			if to_target < 20:
				return
		LOOKING_FOR.BED:
			if to_target < 10:
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
	
	move_to(self.global_position.direction_to(nav.get_next_path_position()), delta)

# Movement 

func move_to(direction, delta):
	is_moving = true
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
	var treesPos = treeTiles.get_used_cells().map(treeTiles.map_to_local)
	# find closest tree
	var closest = treesPos[0]
	for tree in treesPos:
		var dis_to_close = global_position.distance_to(closest)
		var dis_to_curTree = global_position.distance_to(tree)
		
		if dis_to_curTree < dis_to_close:
			closest = tree
	_target = closest

func cut_wood() -> void:
	if global_position.distance_to(_target) < 10:
		var tree_map_pos = treeTiles.local_to_map(_target)
		treeTiles.set_cell(tree_map_pos,0)
		Global.inventory_dict[Global.RESOURCES_TRACKED.WOOD] += 2
		
		_target = null
		pass

# Building stooooooof
func find_building() -> void:
	if Global.build_queue.size() <= 0:
		return
	var building = Global.build_queue[0]
	_target = building.south.global_position

# Sleep
func find_bed() -> void:
	if !bed:
		_target = null
		return
	_target = bed.global_position

# Planting
var plant : Crop

func find_plant() -> void:
	var crops = get_tree().get_nodes_in_group("CROP")
	# filter for already planted crops
	crops = crops.filter(func(element):return !element.planted) 
	if crops.size() <= 0:
		return
	
	var closest = crops[0]
	for crop in crops:
		var dis_to_close = global_position.distance_to(closest.global_position)
		var dis_to_cur = global_position.distance_to(crop.global_position)
		
		if dis_to_cur < dis_to_close:
			closest = crop
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
	var crops = get_tree().get_nodes_in_group("CROP")
	# filter for only fully grown crops
	crops = crops.filter(func(element): return element.grown)
	if crops.size() <= 0:
		_target = null
		return
	
	var closest = crops[0]
	for crop in crops:
		var dis_to_close = global_position.distance_to(closest.global_position)
		var dis_to_cur = global_position.distance_to(crop.global_position)
		
		if dis_to_cur < dis_to_close:
			closest = crop
	_target = closest.global_position
	plant = closest

func harvest_plant() -> void:
	if !plant:
		return
	plant.time = 0.0
	plant.planted = false
	plant.grown = false
	Global.inventory_dict[Global.RESOURCES_TRACKED.FOOD] += 2
	_target = null
	plant = null

# Utility AI
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
