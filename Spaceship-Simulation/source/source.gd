extends Node2D

export (float) var radius : float = 128

export (PackedScene) var resource_scene : PackedScene

var _random : RandomNumberGenerator

func _ready() -> void:
	_random = RandomNumberGenerator.new()
	_random.randomize()
	
func get_resource_at_random():
	var inside_unit_circle : Vector2 = Vector2(_random.randf_range(-1, 1), _random.randf_range(-1, 1)).clamped(1)
	var resource_relative_position : Vector2 = inside_unit_circle * radius
	
	var resource = resource_scene.instance()
	resource.global_position = global_position + resource_relative_position
	
	return resource
	
func _draw():
	draw_circle(Vector2(), radius, Color(.5, .5, 0, .2))
