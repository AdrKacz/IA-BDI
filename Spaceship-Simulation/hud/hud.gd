extends CanvasLayer

func update_resources(value):
	$TotalResources.text = str(value)


func _on_TextureButton_pressed():
	get_tree().change_scene("res://menu/menu.tscn")
