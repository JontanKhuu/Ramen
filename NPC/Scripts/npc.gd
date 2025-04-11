extends CharacterBody2D
class_name Villager

enum LOOKING_FOR{
	NONE, WOOD, BUILDING, BED
}

@export var speed := 100

@export var task : LOOKING_FOR
@export var job : Global.JOB
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
	if !_target:
		_target = null
		# if it's still looking for wood, try to find a new target
		match task:
			LOOKING_FOR.WOOD:
				find_wood()
			LOOKING_FOR.BUILDING:
				find_building()
		return
	
	nav.target_position = _target
	
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
	var WAN_DIS = 60
	var start_pos = global_position
	var des_pos = start_pos + Vector2(randf_range(-WAN_DIS,WAN_DIS),randf_range(-WAN_DIS,WAN_DIS))
	_target = des_pos

func _on_wander_timer_timeout() -> void:
	print("ok")
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
		Global.wood += 2
		
		_target = null
		pass

# Building stooooooof
func find_building() -> void:
	if Global.build_queue.size() <= 0:
		return
	var building = Global.build_queue[0]
	_target = building.south.global_position

func _on_utility_ai_agent_top_score_action_changed(top_action_id):
	print("Action changed: %s" % top_action_id)
	match top_action_id:
		"idle":
			task = LOOKING_FOR.NONE
			wander()
		"cut_wood":
			task = LOOKING_FOR.WOOD
		"build":
			task = LOOKING_FOR.BUILDING
