extends Node2D

var surplus : int

func birth_chance() -> void:
	surplus = calculate_housing_crisis()
	if surplus > 0:
		for i in range(surplus):
			find_empty_house()
	pass

func calculate_housing_crisis() -> int:
	var beds : int = 0
	beds += get_tree().get_nodes_in_group("HOUSE").size() * 2
	beds += get_tree().get_nodes_in_group("TENT").size() * 2
	var people : int = get_tree().get_nodes_in_group("VILLAGER").size()
	var surplus = beds - people
	return surplus

func find_empty_house() :
	# check if space in each home
	var homes : Array = get_tree().get_nodes_in_group("HOUSE")
	for home : House in homes:
		if home.has_space():
			run_birth_chance(home)
			
func run_birth_chance(home : House) -> void:
	# run chance for birth
	var rand : int = randi() % 10 + 1
	if rand >= 6:
		home.birth()
		surplus -= 1
