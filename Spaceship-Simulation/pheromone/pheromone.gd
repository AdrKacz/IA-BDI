extends Area2D
class_name Pheromone

export (float) var evaporation_time : float = 16

var lifetime : float = 0

func _process(delta) -> void:
	lifetime += delta
	$star_tiny.modulate.a = max(0, 1 - lifetime / evaporation_time)
	if lifetime >= evaporation_time:
		queue_free()
	
func get_strength() -> float:
	return max(0, 1 - lifetime / evaporation_time)
