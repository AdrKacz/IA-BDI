extends Node2D

export (PackedScene) var resource_scene : PackedScene
export (PackedScene) var source_scene : PackedScene

export (int) var number_of_spaceship = 32
export (int) var number_of_initial_source = 4
export (int) var number_of_resources_per_source = 16

export (float) var minimum_distance_to_home = 512

var _random : RandomNumberGenerator

onready var squared_minimum_distance_to_home : float = minimum_distance_to_home * minimum_distance_to_home

func _ready():
	_random = RandomNumberGenerator.new()
	_random.randomize()
	$Background.material.set_shader_param("random_key", _random.randf_range(0.0, 1000.0))
	
	for _i in range(number_of_spaceship):
		var spaceship: Spaceship = $Home.get_spaceship_at_random()
		$Spaceships.add_child(spaceship)
	
	var viewport_size : Vector2 = get_viewport().get_visible_rect().size
	var max_retry : int = 100
	var retry : int = 0
	for _i in range(number_of_initial_source):
		var source_position : Vector2 = Vector2(_random.randf_range(-viewport_size.x / 2, viewport_size.x / 2), _random.randf_range(-viewport_size.y / 2, viewport_size.y / 2))
		while retry < max_retry and source_position.distance_squared_to(Vector2(0, 0)) < squared_minimum_distance_to_home:
			source_position = Vector2(_random.randf_range(-viewport_size.x / 2, viewport_size.x / 2), _random.randf_range(-viewport_size.y / 2, viewport_size.y / 2))
			retry += 1
		if retry >= max_retry:
			break
		var source = source_scene.instance()
		source.position = source_position
		$Sources.add_child(source)
		fill_source(source)

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("create_spaceship"):
		var spaceship: Spaceship = $Home.get_spaceship_at_random()
		$Spaceships.add_child(spaceship)
		
	if event is InputEventMouseButton and event.pressed:
		if event.position.y < 50:
			return
		if event.button_index == BUTTON_LEFT:
			# Create resource
			var resource = resource_scene.instance()
			resource.position = get_global_mouse_position()
			$Resources.add_child(resource)
		elif event.button_index == BUTTON_RIGHT:
			# Create source
			var source = source_scene.instance()
			source.position = get_global_mouse_position()
			$Sources.add_child(source)
			fill_source(source)

func fill_source(source : Source) -> void:
	for _i in range(number_of_resources_per_source):
			var resource = source.get_resource_at_random()
			$Resources.add_child(resource)
			
func add_pheromone(pheromone : Pheromone) -> void:
	$Pheromones.add_child(pheromone)

func _on_Home_resources(number_of_resources):
	$HUD.update_resources(number_of_resources)
