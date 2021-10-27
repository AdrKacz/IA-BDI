extends KinematicBody2D

export (float) var max_speed : float = 50
export (float) var steer_strength : float = 50
export (float) var wander_strength : float = 0.2

export (float) var _view_angle : float = 140
export (float) var pick_up_radius : float = 8

var _velocity : Vector2 = Vector2()
var _desired_direction : Vector2 = Vector2()
var _random : RandomNumberGenerator

var _has_target : bool = false
var _target : RigidBody2D

onready var squared_pick_up_radius : float = pick_up_radius * pick_up_radius

func _ready():
	_random = RandomNumberGenerator.new()
	_random.randomize()

func handle_supply():
	if _has_target:
		
		
		if position.distance_squared_to(_target.position) < squared_pick_up_radius:
			_has_target = false
			_target.queue_free()
	else:
		for body in $Radar.get_overlapping_bodies():
			if body.is_in_group('supply'):
				# Start targeting the food it is within the view angle
				var angle : float =  transform.x.angle_to((body.position - position).normalized())
				if deg2rad(-_view_angle / 2) < angle and angle < deg2rad(_view_angle / 2):
					_target = body
					_has_target = true
		
func _physics_process(delta : float):
	handle_supply()
	# Target
	if _has_target:
		_desired_direction = (_target.position - position).normalized()
	else:
		var inside_unit_circle : Vector2 = Vector2(_random.randf_range(-1, 1), _random.randf_range(-1, 1)).clamped(1)
		_desired_direction = (_desired_direction + inside_unit_circle * wander_strength).normalized()
		
	# Movement
	var desired_velocity : Vector2 = _desired_direction * max_speed
	var desired_streering_force : Vector2 = (desired_velocity - _velocity) * steer_strength
	var acceleration : Vector2 = desired_streering_force.clamped(steer_strength) / 1
	
	_velocity = (_velocity + acceleration * delta).clamped(max_speed)
	_velocity = move_and_slide(_velocity)
	
	# Rotation
	var angle : float = atan2(_velocity.y, _velocity.x)
	rotation = angle
	
	


func draw_circle_arc_poly(center : Vector2, radius : float, angle_from : float, angle_to : float, color : Color):
	var nb_point : int = 32
	var points_arc : PoolVector2Array = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])
	
	for i in range(nb_point + 1):
		var angle_point : float = deg2rad(angle_from + i * (angle_to - angle_from) / nb_point)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)

func _draw():
	draw_circle_arc_poly(Vector2(), $Radar/CollisionShape2D.shape.radius, -_view_angle / 2, _view_angle / 2, Color(0.8, 0.3, 0.1, 0.5))
	draw_circle(Vector2(), pick_up_radius, Color(0.1, 0.8, 0.5, 0.8))
	
