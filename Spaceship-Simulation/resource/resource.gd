extends RigidBody2D

export (int) var resources : int = 1

var _will_queue_free : bool = false

func collect_resources(quantity : int) -> int:
	if resources > quantity:
		resources -= quantity
		return quantity
	else:
		var temp : int = resources
		resources = 0
		$icon_plusSmall.modulate.a = .0
#		queue_free_with_delay()
		return temp

#func queue_free_with_delay() -> void:
#	return
#	if not _will_queue_free:
#		_will_queue_free = true
#		yield(get_tree().create_timer(10), "timeout")
#		queue_free()
