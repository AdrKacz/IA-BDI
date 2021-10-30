extends KinematicBody2D
class_name Spaceship

#const FORWARD : Vector2 = Vector2(1, 0)
#const LEFT : Vector2 = Vector2(0, -1)
#const RIGHT : Vector2 = Vector2(0, 1)

export (PackedScene) var resources_pheromone_scene : PackedScene
export (PackedScene) var home_pheromone_scene : PackedScene

export (float) var max_speed : float = 50
export (float) var steer_strength : float = 50
export (float) var wander_strength : float = 0.2

export (float) var _view_angle : float = 140
export (float) var pick_up_radius : float = 8

export (int) var pick_up_capacity : int = 10

var _is_looking_for_resources : bool = true

var _velocity : Vector2 = Vector2()

var _random : RandomNumberGenerator

var _target : Node2D

onready var _squared_pick_up_radius : float = pick_up_radius * pick_up_radius

onready var _desired_direction : Vector2 = transform.x


var _temp = Vector2()

func _ready() -> void:
	_random = RandomNumberGenerator.new()
	_random.randomize()
	
func handle_pheromone_steering() -> void:
	$Sensors/Left.update_value(_is_looking_for_resources)
	$Sensors/Centre.update_value(_is_looking_for_resources)
	$Sensors/Right.update_value(_is_looking_for_resources)
	
	if $Sensors/Centre._value > max($Sensors/Left._value, $Sensors/Right._value):
		_desired_direction = transform.x
	elif $Sensors/Left._value > max($Sensors/Centre._value, $Sensors/Right._value):
		_desired_direction = (transform.x - transform.y).normalized()
	elif $Sensors/Right._value > max($Sensors/Left._value, $Sensors/Centre._value):
		_desired_direction = (transform.x + transform.y).normalized()
		
func _change_state():
	_is_looking_for_resources = not _is_looking_for_resources
	if _is_looking_for_resources:
		$ship_empty.visible = true
		$ship_full.visible = false
	else:
		$ship_empty.visible = false
		$ship_full.visible = true
	_desired_direction = -transform.x

func handle_target() -> void:
	if _target:
		if position.distance_squared_to(_target.global_position) < _squared_pick_up_radius:
			if _is_looking_for_resources and _target.has_method("collect_resources"):
				var _resources_collected : int = _target.collect_resources(pick_up_capacity)
				_change_state()
			else:
				if _target.has_method("retrieve_resource"):
					_target.retrieve_resource()
					_change_state()
			_target = null
	else:
		if _is_looking_for_resources:
			for body in $Radar.get_overlapping_bodies():
				if body.has_method('collect_resources') and body.resources > 0:
					# Start targeting the resource it is within the view angle
					var angle : float =  transform.x.angle_to((body.position - position).normalized())
					if deg2rad(-_view_angle / 2) < angle and angle < deg2rad(_view_angle / 2):
						_target = body
						_temp = (_target.position - position).normalized()
		else:
			for area in $Radar.get_overlapping_areas():
				if area.is_in_group('home'):
					# Start targeting the base it is within the view angle
					var angle : float =  transform.x.angle_to((area.position - position).normalized())
					if deg2rad(-_view_angle / 2) < angle and angle < deg2rad(_view_angle / 2):
						_target = area

func _physics_process(delta : float) -> void:
	handle_target()
	
	if _target:
		_desired_direction = (_target.position - position).normalized()
	else:
		handle_pheromone_steering()
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
	
func draw_circle_arc_poly(center : Vector2, radius : float, angle_from : float, angle_to : float, color : Color) -> void:
	var nb_point : int = 32
	var points_arc : PoolVector2Array = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])
	
	for i in range(nb_point + 1):
		var angle_point : float = deg2rad(angle_from + i * (angle_to - angle_from) / nb_point)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)


func _process(_delta) -> void:
	if _is_looking_for_resources and _target:
		if _target.resources <= 0:
			_target = null
	
func _draw() -> void:
	pass
#	draw_circle_arc_poly(Vector2(), $Radar/CollisionShape2D.shape.radius, -_view_angle / 2, _view_angle / 2, Color(0.8, 0.3, 0.1, 0.5))
#	draw_circle(Vector2(), pick_up_radius, Color(0.1, 0.8, 0.5, 0.8))
#
#	draw_line(Vector2(), FORWARD * $Radar/CollisionShape2D.shape.radius, Color.aquamarine, 2)
#	draw_line(Vector2(), LEFT * $Radar/CollisionShape2D.shape.radius, Color.red, 2)
#	draw_line(Vector2(), RIGHT * $Radar/CollisionShape2D.shape.radius, Color.green, 2)
	


func _on_PheromoneTimer_timeout() -> void:
	var pheromone : Pheromone
	if _is_looking_for_resources:
		pheromone = home_pheromone_scene.instance()
	else:
		pheromone = resources_pheromone_scene.instance()
	pheromone.global_position = global_position
	get_parent().get_parent().add_pheromone(pheromone)
