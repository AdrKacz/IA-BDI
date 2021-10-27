extends KinematicBody2D

export (float) var max_speed = 50
export (float) var steer_strength = 50
export (float) var wander_strength = 0.2

var _velocity : Vector2 = Vector2()
var _desired_direction : Vector2 = Vector2()
var _random : RandomNumberGenerator

func _ready():
	_random = RandomNumberGenerator.new()
	_random.randomize()

func _process(delta):
	var inside_unit_circle = Vector2(_random.randf_range(-1, 1), _random.randf_range(-1, 1)).clamped(1)
	_desired_direction = (_desired_direction + inside_unit_circle * wander_strength).normalized()
	
	var desired_velocity = _desired_direction * max_speed
	var desired_streering_force = (desired_velocity - _velocity) * steer_strength
	var acceleration = desired_streering_force.clamped(steer_strength) / 1
	
	_velocity = (_velocity + acceleration * delta).clamped(max_speed)
	move_and_slide(_velocity)
	
	var angle = atan2(_velocity.y, _velocity.x)
	rotation = angle


func _draw():
	draw_circle(Vector2(), $Area2D/CollisionShape2D.shape.radius, Color.red)
