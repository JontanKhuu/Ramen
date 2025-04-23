extends CharacterBody2D

@export var speed := 100

@onready var tiles : Node2D = get_node("/root/World/TileMap")
@onready var grassTiles : TileMapLayer = tiles.get_child(0)
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var sprite_2d: Sprite2D = $Sprite2D

var _target

var aStar : AStarGrid2D
var path_points : Array

func _ready() -> void:
	_target = get_tree().get_first_node_in_group("TENT").entrance.global_position
	aStar = tiles.aStar

func _process(delta: float) -> void:
	if !_target:
		return
	var to_target = self.global_position.distance_to(_target)
	if to_target < 5:
		_target = null
		velocity = Vector2.ZERO
		nav.emit_signal("navigation_finished")
	elif to_target > 5:
		_handle_navigation_path()
	
	var direction = self.global_position.direction_to(nav.get_next_path_position())
	move_to(direction, delta)

func move_to(direction, delta):
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
