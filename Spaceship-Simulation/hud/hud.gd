extends CanvasLayer

var _is_fast : bool = false

func update_resources(value):
	$TotalResources.text = str(value)

func _on_Pause_pressed():
	var _error_code = get_tree().change_scene("res://menu/menu.tscn")

func _on_FastForward_pressed():
	if _is_fast:
		Engine.set_time_scale(1)
	else:
		Engine.set_time_scale(4)
	_is_fast = not _is_fast
	$FastForward.visible = not $FastForward.visible
	$NormalSpeed.visible = not $NormalSpeed.visible
