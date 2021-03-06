# IA-BDI, Multi-Agent spaceship

*[@AdrKacz](https://github.com/AdrKacz), [@mbeaufre](https://github.com/mbeaufre), Master Artificial Intelligence Ecole Centrale Lyon - Lyon 1*

*If you have any questions, please contact us, or raise an Issue or a Pull Request*

This repository host the code for a 2D simulation of multiple spaceships travelling through infinity to gather resources.

Spaceships are only aware of what is in front of them and can release markers that diffuse over time.

Resources are gathered by group in space.

## How to run the simulation

Go to [itch - Spaceship Simulation](https://adrkacz.itch.io/spaceship-simulation), and click **Run project**.

*You can write any suggestion you have below the project.*

## I want to edit and run the project

1. Go to [Godot](https://godotengine.org/download) official website and download the engine you need.

2. Clone this Git Repository
```
git clone https://github.com/AdrKacz/IA-BDI.git
```

3. Open **Godot**, and *scan* the folder you've just imported. The project *Spaceship-Simulation* should appear. Double-click on it to open it. Once done, click on the *Play* icon at the top right of your screen to launch it.

4. To learn more about Godot, go to their superb [documentation](https://docs.godotengine.org/en/stable/).

# The problem

Our home is lost in space and needs to retrieve **resources** around to survive.

You can release **spaceships** to go look for nearby resources.

However, spaceships don't have an efficient radar, and pilots only see what is **not too far and in front** of them.

To help them in their quest, pilots can release **markers** in space while flying. These markers evaporate and **lose visibility over time**.

Once they left their home, pilots have **no idea where they are**, and how to find back their home.

**Space is great and dark.**

*Good luck!*

# Spaceship strategy

The *spaceship* will wander until it finds a target. If it doesn't carry a resource, it will look for a **resource**. If it transports a resource, it will look for its **home**.

While leaving its home, the *spaceship* will release *blue markers*, to indicate the way back home.

After finding a resource, the *spaceship* will release *red markers*, to indicate where resources are.

*In code, "marker" is replaced with "pheromone". It mainly takes its influence from pheromone phenomenons in ants.*

The *spaceships* has six sensors in front of it to measure the concentration of markers. Three *blue sensors* are for *blue markers* and three *red sensors* are for *red markers*.

The *blue sensors* and *red sensors* are laid out the same. One to the left at **-45??**, one just in front at **0??**, and one to the right at **+45??**.

The *spaceship* will change its `_desired_direction` based on the value measured with its sensors.

`_desired_direction` is the direction spaceship try to move in. The direction is controlled by two hyper-parameters  `steer_strength`, and `max_speed`.

The more `steer_strength` is significant, the more the spaceship can accelerate to reach its `_desired_direction`.

`max_speed` is the velocity maximum of the spaceship.

```py
func _physics_process(delta : float) -> void:
  # ...
  # Assign _desired_direction
  # ...

  # Movement
  var desired_velocity : Vector2 = _desired_direction * max_speed
  var desired_streering_force : Vector2 = (desired_velocity - _velocity) * steer_strength
  var acceleration : Vector2 = desired_streering_force.clamped(steer_strength) / 1

  _velocity = (_velocity + acceleration * delta).clamped(max_speed)
  _velocity = move_and_slide(_velocity)

  # Rotation
  var angle : float = atan2(_velocity.y, _velocity.x)
  rotation = angle
```

## Releasing markers

Just after release, markers are entirely visible. Then, they lose intensity linearly over `evaporation_time` seconds.

```py
func get_strength() -> float:
  return max(0, 1 - lifetime / evaporation_time)
```

## Following markers

To measure sensor value, the *sensor* adds up the strength of each marker in its zone.

```py
func update_value(look_for_resources) -> void:
  # Follow the way back (to move back and forth between source and home)
  _value = 0
    if look_for_resources:
      for area in $Resources.get_overlapping_areas():
        var pheromone := area as Pheromone
        _value += pheromone.get_strength()
    else:
    for are a in $Home.get_overlapping_areas():
      var pheromone := area as Pheromone
      _value += pheromone.get_strength()

  _value = min(saturation_value, _value)
  # Change alpha colour of sensor based on its _value
  # ...
```

This value cannot be greater than the `saturation_value` of the sensor.

This hyper-parameter avoid extreme concentration of agents at the same point.

Indeed, if numerous agents coming from opposite directions gather at the same point, they can start following each other at this point, and their sensor value will skyrocket.

Thus, they cannot escape this trap because the marker concentration became too important. Saturation let the *agent* be distracted by other sources even if stuck in a loop.

To determine in which direction the *spaceship* goes, it updates the values of its **3** sensors (depending on its state, the *blue* ones if it's looking for a home, the *red* ones if it's looking for resources).

Then it goes either **forward**, **left**, or **right**.

![Spaceships Sensors](./previews/IA-schemas/markers-steering.jpeg)

```py
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
```

## Lookup for targets

The spaceship looks in front of it. If it finds a *target* of the type it is looking for (either its *home* or *resources*), it moves towards it.

```py
func _physics_process(delta : float) -> void:
	handle_target()

	if _target:
		_desired_direction = (_target.position - position).normalized()
	else:
		handle_pheromone_steering()
		var inside_unit_circle : Vector2 = Vector2(_random.randf_range(-1, 1), _random.randf_range(-1, 1)).clamped(1)
		_desired_direction = (_desired_direction + inside_unit_circle * wander_strength).normalized()

  # Handle Movement
  # ...
```

To find a target, spaceship has a `Radar` defined in `./Spaceship-Simulation/spaceship/spaceship.tscn`.

```py
# ...
[sub_resource type="CircleShape2D" id=2]
radius = 96.0
# ...
[node name="Radar" type="Area2D" parent="."]
collision_layer = 0
collision_mask = 4

[node name="CollisionShape2D" type="CollisionShape2D" parent="Radar"]
visible = false
shape = SubResource( 2 )
# ...
```

The `Radar` detects objects in the nearby areas of the *spaceship*. Objects are processed if they are in the **field of view**.

The field of view is all the points within the `Radar` area and within a given `_view_angle` range. So, *spaceship* doesn't see what's behind it.

```py
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
```


# Previews

The number in **red** is the number of resources that returns to the base.

When the spaceship is *close* and releases **blue** markers, it doesn't carry resources, and it's looking for some.

When the spaceship is *open* and releases **red** markers, it carries resources, and it's looking for its base.

![Spaceships leave home](./previews/preview-start-gif.gif)

At first, we observe **blue** markers everywhere. However, they quickly diffuse, and paths appear.

We notice that some spaceships go in the wrong direction. That is because they don't have any idea where they are. However, thanks to markers, they recover their way to the desired path (*as you can see with the one on the middle right doing a loop*).


![Spaceships trace route](./previews/preview-end-gif.gif)

After a while, we observed a well-drawn markers trail, making a total of **3** paths. **2** to go to the left resource batch, and **1** to go to the resource batch to the right.

We notice that the metric that displayed the number of resources returning to the base goes up way quicker than at the beginning of the simulation. So spaceships succeed in creating an efficient group behaviour to gather resources.


# Details on graphics

We won't detail here how we display information on the screen.

Indeed, *Game Simulation* or *Computer Graphics* are not the subject of the study.

If you want to know how something is correctly displayed, we will be happy to answer your questions.

# Infinite space issue

Space has no bound, and spaceships quickly get lost and never find their home back.

To avoid this problem, we can simulate fictional space boundaries. We will have to add an edges detection system to the spaceship.

Another solution is to attract all spaceships to home if they are too far.

These two solutions are artificial and do not translate the emptiness of space.

A more realistic solution is to ask each spaceship to store its `_desired_direction`'s overtime. Thus it can estimate its distance from home. Then revert its `_desired_direction`'s when it's too far.


# Conclusion

Working on this topic was extremely fun! We had to simplify the subject at most and find an exciting way to display the information so anyone could understand and have fun with it.

We decided to keep from the planet only the idea of aggregation of resources. And we display the information using a visual simulation. Indeed, this problem heavily involves movement, and it's easier to catch and see if things are working when you see them.

We had to learn how ants work to find their way to food and their way back home. We simplify this process and keep only two markers and a small field of view. In reality, ants can communicate when there is no more food, and they can recognise their environment to find the most efficient path.

We were short on time, but we would have loved to continue working on this subject a bit longer.

Here are some potential ameliorations:

1. Add collision detection and avoidance (*to go around asteroids*).

2. Optimise simulation to run with more than **500** spaceships.

3. Have multiple bases, and multiple spaceship teams (maybe some team).

4. Have multiple spaceships (*spaceships to collect resources and spaceships to attack other spaceships*).

5. Implement a Reinforcement Learning Algorithm on spaceships instead of the straightforward *if-else* algorithm implemented.

*If you're interested, we may update this repository in the future.*
