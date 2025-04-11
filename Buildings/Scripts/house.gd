extends StaticBody2D
class_name House

@export var slot1 : CharacterBody2D
@export var slot2 : CharacterBody2D

@onready var bed: Node2D = $bed

@onready var villager = get_tree().get_nodes_in_group("VILLAGER")

func _ready() -> void:
	assign_homes()
	


# will probably call assign homes again every at end of every rest period
func assign_homes() -> void:
	for unit in villager:
		if slot1 && slot2:
			break
		if unit.bed != null:
			continue
			
		if slot1 == null:
			slot1 = unit
			unit.bed = bed
		elif slot2 == null:
			slot2 = unit
			unit.bed = bed
		
		pass
	pass
