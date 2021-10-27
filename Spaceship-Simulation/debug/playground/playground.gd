extends Node2D

export (PackedScene) var Supply : PackedScene

var _dragging = false
var _click_radius = 32

func _input(event : InputEvent):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if (event.position - $Target.position).length() < _click_radius:
			# Start dragging if the click is on the sprite
			if not _dragging and event.pressed:
				_dragging = true
		elif event.pressed:
			# Create supply
			var supply : RigidBody2D = Supply.instance()
			supply.position = event.position
			add_child(supply)
		# Stop dragging if the button is released
		if _dragging and not event.pressed:
			_dragging = false
	
	if event is InputEventMouseMotion and _dragging:
		# While dragging, move the sprite with the mouse
		$Target.position = event.position
