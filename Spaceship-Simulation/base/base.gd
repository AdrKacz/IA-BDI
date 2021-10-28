extends Area2D

export (PackedScene) var spaceship_scene : PackedScene

var _random : RandomNumberGenerator

func _ready() -> void:
	_random = RandomNumberGenerator.new()
	_random.randomize()
	
func get_spaceship_at_random():
	var inside_unit_circle : Vector2 = Vector2(_random.randf_range(-1, 1), _random.randf_range(-1, 1)).clamped(1)
	var spaceship_relative_position : Vector2 = inside_unit_circle * $CollisionShape2D.shape.radius
	
	var spaceship : Spaceship = spaceship_scene.instance()
	spaceship.global_position = global_position + spaceship_relative_position
	
	var angle : float = atan2(spaceship_relative_position.y, spaceship_relative_position.x)
	spaceship.rotation = angle
	
	return spaceship
