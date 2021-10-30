extends Area2D
class_name Pheromone

export (float) var evaporation_time : float = 32

var lifetime : float = 0

func _process(delta) -> void:
	lifetime += delta
	$star_tiny.modulate.a = get_alpha(lifetime)
	if lifetime >= evaporation_time:
		queue_free()
		
func get_alpha(value) -> float:
#	return (exp(-value) - exp(-evaporation_time)) / (1 - exp(-evaporation_time))
	return max(0, 1 - value / evaporation_time)
	
func get_strength() -> float:
	return max(0, 1 - lifetime / evaporation_time)
