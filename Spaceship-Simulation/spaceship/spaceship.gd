extends KinematicBody2D
class_name Spaceship

const FORWARD : Vector2 = Vector2(1, 0)
const LEFT : Vector2 = Vector2(0, -1)
const RIGHT : Vector2 = Vector2(0, 1)

export (PackedScene) var resources_pheromone_scene : PackedScene
export (PackedScene) var home_pheromone_scene : PackedScene

export (float) var max_speed : float = 50
export (float) var steer_strength : float = 50
export (float) var wander_strength : float = 0.1

export (float) var _view_angle : float = 140
export (float) var pick_up_radius : float = 8

export (int) var pick_up_capacity : int = 10

var _is_looking_for_resources : bool = true

var _velocity : Vector2 = Vector2()
var _desired_direction : Vector2

var _random : RandomNumberGenerator

var _target : Node2D

onready var _squared_pick_up_radius : float = pick_up_radius * pick_up_radius


var _temp = Vector2()

func _ready() -> void:
	_random = RandomNumberGenerator.new()
	_random.randomize()
	setup()

func setup() -> void:
	_desired_direction = FORWARD
	
func handle_pheromone_steering() -> void:
	$LeftSensor.update_value(_is_looking_for_resources)
	$CentreSensor.update_value(_is_looking_for_resources)
	$RightSensor.update_value(_is_looking_for_resources)
	
	if $CentreSensor._value > max($LeftSensor._value, $RightSensor._value):
		print('Forward')
	elif $LeftSensor._value > max($CentreSensor._value, $RightSensor._value):
		_desired_direction += LEFT * 100
		print('Left')
	elif $RightSensor._value > max($LeftSensor._value, $CentreSensor._value):
		_desired_direction += RIGHT * 100
		print('Right')

func handle_supply() -> void:
	if _target:
		if position.distance_squared_to(_target.global_position) < _squared_pick_up_radius:
			if _target.collect_resources(pick_up_capacity) > 0:
				_is_looking_for_resources = false
			_target = null
				
	else:
		for body in $Radar.get_overlapping_bodies():
			if body.has_method('collect_resources') and body.resources > 0:
				# Start targeting the supply it is within the view angle
				var angle : float =  transform.x.angle_to((body.position - position).normalized())
				if deg2rad(-_view_angle / 2) < angle and angle < deg2rad(_view_angle / 2):
					_target = body
					_temp = (_target.position - position).normalized()

func handle_base() -> void:
	if _target:
		if position.distance_squared_to(_target.global_position) < _squared_pick_up_radius:
			_is_looking_for_resources = true
			_target = null
	else:
		for body in $Radar.get_overlapping_bodies():
			if body.is_in_group('base'):
				# Start targeting the base it is within the view angle
				var angle : float =  transform.x.angle_to((body.position - position).normalized())
				if deg2rad(-_view_angle / 2) < angle and angle < deg2rad(_view_angle / 2):
					_target = body

func _physics_process(delta : float) -> void:
	
	if _is_looking_for_resources:
		handle_supply()
	else:
		handle_base()
		
	if _target:
		_desired_direction = (_target.position - position).normalized()
	else:
		handle_pheromone_steering()
		var inside_unit_circle : Vector2 = Vector2(_random.randf_range(-1, 1), _random.randf_range(-1, 1)).clamped(1)
		_desired_direction = (_desired_direction + inside_unit_circle * 0).normalized()
		
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
	update()
	
func _draw() -> void:
	draw_circle_arc_poly(Vector2(), $Radar/CollisionShape2D.shape.radius, -_view_angle / 2, _view_angle / 2, Color(0.8, 0.3, 0.1, 0.5))
	draw_circle(Vector2(), pick_up_radius, Color(0.1, 0.8, 0.5, 0.8))
		
	draw_line(Vector2(), FORWARD * $Radar/CollisionShape2D.shape.radius, Color.aquamarine, 2)
	draw_line(Vector2(), LEFT * $Radar/CollisionShape2D.shape.radius, Color.red, 2)
	draw_line(Vector2(), RIGHT * $Radar/CollisionShape2D.shape.radius, Color.green, 2)
	


func _on_PheromoneTimer_timeout() -> void:
	var pheromone : Pheromone
	if _is_looking_for_resources:
		pheromone = home_pheromone_scene.instance()
	else:
		pheromone = resources_pheromone_scene.instance()
	pheromone.global_position = global_position
	get_parent().add_child(pheromone)
