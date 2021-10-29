extends Node2D
class_name Sensor

export (float) var saturation_value : float = 10

var _value : float = 0

func update_value(look_for_resources) -> void:
	# Follow the way back (to move back and forth between source and home)
	_value = 0
	if look_for_resources:
		for area in $Resources.get_overlapping_areas():
			var pheromone := area as Pheromone
			_value += pheromone.get_strength()
	else:
		for area in $Home.get_overlapping_areas():
			var pheromone := area as Pheromone
			_value += pheromone.get_strength()
			
	_value = min(saturation_value, _value)
	$icon_exclamationSmall.modulate.a = _value / saturation_value
	
