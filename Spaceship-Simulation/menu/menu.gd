extends CanvasLayer

const simulation_scene : PackedScene = preload("res://simulation/simulation.tscn")

var _random : RandomNumberGenerator

func _ready():
	Engine.set_time_scale(1)
	_random = RandomNumberGenerator.new()
	_random.randomize()
	
	$Background.material.set_shader_param("random_key", _random.randf_range(0.0, 1000.0))
	$BackgroundBig.material.set_shader_param("random_key", _random.randf_range(0.0, 1000.0))

func _on_TextureButton_pressed():
	var _error_code = get_tree().change_scene_to(simulation_scene)
