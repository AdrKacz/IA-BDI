extends RigidBody2D
export (int) var resources : int = 10

func collect_resources(quantity : int):
	if resources > quantity:
		resources -= quantity
		return quantity
	else:
		var temp : int = resources
		resources = 0
		$icon_plusSmall.modulate = Color(0, 0, 1)
		return temp
