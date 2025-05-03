extends CharacterBody2D

@export var speed := 80
@export var wander_distance : float = 100
@export var meat_amount : int
@export var leather_amount : int

@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var wander_timer: Timer = $WanderTimer

var _target
func _ready() -> void:
	wander()

func _process(delta: float) -> void:
	_handle_target()

func wander():
	# wander a certain distance from current point
	var WAN_DIS = wander_distance
	var start_pos = global_position
	var des_pos = start_pos + Vector2(randf_range(-WAN_DIS,WAN_DIS),randf_range(-WAN_DIS,WAN_DIS))
	_target = des_pos

func _handle_target():
	if _target == null:
		return
		
	nav.target_position = _target
	var to_target = self.global_position.distance_to(_target)
	if to_target < 5 or nav.is_navigation_finished():
		wander_timer.start()
		_target = null
	
	var direction = self.global_position.direction_to(nav.get_next_path_position())
	move_to(direction)

func move_to(direction):
	var new_velocity = direction * speed
	velocity = new_velocity
	
	if nav.avoidance_enabled:
		nav.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
		
	move_and_slide()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity


func _on_wander_timer_timeout() -> void:
	wander()
