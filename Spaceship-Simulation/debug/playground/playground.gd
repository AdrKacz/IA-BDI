extends Node2D

export (PackedScene) var supply_scene : PackedScene

export (int) var number_of_spaceship = 1

func _ready():
	for _i in range(number_of_spaceship):
		var spaceship: Spaceship = $Base.get_spaceship_at_random()
		add_child(spaceship)
		spaceship.setup()

func _input(event : InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		# Create supply
		var supply : Supply = supply_scene.instance()
		supply.position = event.position
		add_child(supply)
