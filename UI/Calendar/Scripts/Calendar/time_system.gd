class_name TimeSystem extends Node 

const EVENT = preload("res://NPC/Scenes/event_npc.tscn")

signal updated

@export var date_time: DateTime 
@export var ticks_per_second: int = 10000 # Change the int here to increase/decrease speed of time

@onready var eventSpawn = get_tree().get_first_node_in_group("EVENTSPAWN")
# Add event and check what time of date it should trigger.
var events = {
	"Trader Spawn": {"days": 1,"hours": 14,"minutes": 30,"action": Callable(self,"trader_spawn")},
	"Money Checkin": {"days": 2,"hours": 8,"minutes": 0,"action": Callable(self,"money_checkin")},
	"Queue Sort Test": {"days": 1,"hours": 2,"minutes": 59,"action": Callable(self,"test_one")},
	"Test Event2": {"days": 1,"hours": 16,"minutes": 4,"action": Callable(self,"test_two")},
	"Trader Spawn2": {"days": 3,"hours": 14,"minutes": 30,"action": Callable(self,"trader_spawn")},
	"Money Checkin2": {"days": 6,"hours": 8,"minutes": 0,"action": Callable(self,"money_checkin")},
	"Queue Sort Test2": {"days": 7,"hours": 2,"minutes": 59,"action": Callable(self,"test_one")},
	"Queue Sort Tes3t": {"days": 4,"hours": 2,"minutes": 59,"action": Callable(self,"test_one")},
	"Test Eve3nt2": {"days": 5,"hours": 16,"minutes": 4,"action": Callable(self,"test_two")},
	"Trader Sp3awn2": {"days": 18,"hours": 14,"minutes": 30,"action": Callable(self,"trader_spawn")},
	"Test Event22": {"days": 12,"hours": 16,"minutes": 4,"action": Callable(self,"test_two")},
	"Test Event222": {"days": 26,"hours": 16,"minutes": 4,"action": Callable(self,"test_two")},
}
	
var previous_day = -1
var event_queue = []

# Function that updates time
func _process(delta:float) -> void:
	date_time.increase_by_sec(delta * ticks_per_second)
	updated.emit(date_time)
	if date_time.days != previous_day:
		previous_day = date_time.days
		parse_sort_events()
		check_events()

func check_events(): # Recursive function to keep calling check_events the all events of the day have been called
	if event_queue.size() == 0:
		return
	var next_event = event_queue[0]
	if date_time.days == next_event.days and date_time.hours == next_event.hours and date_time.minutes == next_event.minutes:
		print("Event Happened")
		next_event.action.call()
		event_queue.pop_front()
		check_events()
	else:
		await get_tree().create_timer(0.01).timeout # await for a small amount of time.
		check_events()
			
func parse_sort_events():
	event_queue.clear() # Clear queue of events
	for event_name in events: # If the current day has any events queue up the events
		var event = events[event_name]
		if date_time.days == event.days:
			event_queue.append(event)
	event_queue.sort_custom(Callable(self,"sort_events"))
	
func sort_events(a,b):
	if a.hours < b.hours:
		return true 
	elif a.hours == b.hours and a.minutes < b.minutes:
		return true 
	else:
		return false

func trader_spawn() -> void: # The actual function
	var merchant = EVENT.instantiate()
	merchant.event_type = merchant.EVENT_TYPE.MERCHANT
	date_time.connect("day_passed",Callable(merchant,"leave"))
	eventSpawn.add_child(merchant)
	print("Trader Spawned")

func money_checkin():
	print("Its time to pay your monthly rent")
	
func test_one():
	print("Event 2")

func test_two():
	print("Event 3")
