extends Node2D

export (PackedScene) var resource_scene : PackedScene

export (int) var number_of_spaceship = 32
export (int) var number_of_resources_per_source = 16

func _ready():
	for _i in range(number_of_spaceship):
		var spaceship: Spaceship = $Base.get_spaceship_at_random()
		add_child(spaceship)
		
	for source in $Sources.get_children():
		for _i in range(number_of_resources_per_source):
			var resource = source.get_resource_at_random()
			add_child(resource)

func _input(event : InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		# Create supply
		var resource = resource_scene.instance()
		resource.position = get_global_mouse_position()
		add_child(resource)


func _on_Base_resources(number_of_resources):
	$HUD.update_resources(number_of_resources)
