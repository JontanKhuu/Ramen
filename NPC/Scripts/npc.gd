extends CharacterBody2D

@export var speed := 100

@export var target : LOOKING_FOR
@export_enum("NONE","LABORER") var job : String

@onready var tiles : Node2D = get_node("/root/World/TileMap")
@onready var grassTiles : TileMapLayer = tiles.get_child(0)
@onready var treeTiles : TileMapLayer = tiles.get_child(1)

enum LOOKING_FOR{
	NONE,
	WOOD
}

var looking_for_wood : bool = false

var is_moving : bool = false
var _target

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	print(_target)
	_handle_target(delta)


func _handle_target(delta: float):
	if !_target:
		_target = null
		# if it's still looking for food, try to find a new target
		if target == LOOKING_FOR.WOOD:
			find_wood()
		return
	
	var to_target = self.global_position.distance_to(_target)
	match target:
		LOOKING_FOR.NONE:
			return
		LOOKING_FOR.WOOD:
			if to_target < 10:
				cut_wood()
				return
	
	move_to(self.global_position.direction_to(_target), delta)

func move_to(direction, delta):
	is_moving = true
	#if direction.x > 0:
		#$Flip.scale.x = 1
		##turn right
	#else:
		## turn left
		#$Flip.scale.x = -1
	# warning-ignore:return_value_discarded
	var new_velocity = direction * speed
	velocity = new_velocity
	move_and_slide()

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
		
		_target = null
		pass

func _on_utility_ai_agent_top_score_action_changed(top_action_id):
	print("Action changed: %s" % top_action_id)
	match top_action_id:
		"idle":
			pass
		"cut_wood":
			target = LOOKING_FOR.WOOD
