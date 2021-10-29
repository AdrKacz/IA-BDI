extends CanvasLayer

const simulation_scene : PackedScene = preload("res://simulation/simulation.tscn")

func _on_TextureButton_pressed():
	get_tree().change_scene_to(simulation_scene)
