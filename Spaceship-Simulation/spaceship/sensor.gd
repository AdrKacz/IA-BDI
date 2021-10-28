extends Area2D
class_name Sensor

var _value : float = 0

func update_value(look_for_resources) -> void:
	# Follow the way back (to move back and forth between source and home)
	_value = 0
	if look_for_resources:
		collision_mask = 0b10000 # 16 -> Resource Pheromone
	else:
		collision_mask = 0b1000 # 8 -> Home Pheromone
	for area in get_overlapping_areas():
		var pheromone := area as Pheromone
		_value += pheromone.get_strength()
