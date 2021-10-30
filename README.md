# IA-BDI, Multi Agent Spaceship


This is a 2D-simulation of multiple spaceships travelling through empty space to gather resources.

Spaceships are only aware of what is in front of them and can release markers that diffuse in space.

Resources are gather by lot in space.

## How to run the simulation

Go to [itch - Spaceship Simulation](https://adrkacz.itch.io/spaceship-simulation), and click **Run project**.

*You can write any suggestion you have below the project.*

### I want to edit and run the project

1. Go to [Godot](https://godotengine.org/download) official website and download the engine you need.

2. Clone this Git Repository
```
git clone https://github.com/AdrKacz/IA-BDI.git
```

3. Open **Godot**, and *scan* the folder you've just imported. The project *Spaceship-Simulation* should appear. Double-click on it to open it. Once done, click on the *Play* icon at the top right of your screen to launch it.

4. To learn more about Godot, go to their superb [documentation](https://docs.godotengine.org/en/stable/).

## The problem

Our home is lost in space and needs to retrieve **resources** around to survive.

You can release **spaceships** to go look for near by resources.

However, spaceships don't have an efficient radar, and pilots only see what is **not too far and in front** of them.

To help them in their quest, pilots can release **markers** in space while flying. These markers evaporate and **lose visibility over time**.

Once they leaved their home, pilots have **no idea where they are**, and how to find back their home.

**Space is great and dark.**

*Good luck!*

## Spaceship strategy

Spaceship will wander until it finds a target. If it doesn't carry a resource it will look for a **resource** and if it carries a resource it will look for its **home**.

While leaving its home, spaceship will release *blue markers*, to indicate the way back home.

After having found a resource, spaceship will release *red markers*, to indicate where resources are.

Spaceship has six sensors in front of it to measure the concentration of markers. Three *blue sensors* are for *blue markers* and three *red sensors* are for *red markers*.

The *blue sensors* and *red sensors* are laid out the same. One to the left at **-45°**, one just in front at **0°**, and one to the right at **+45°**.

Based on the value measured with its sensors, spaceship will change its `_desired_direction`.

`_desired_direction` is the direction spaceship try to move in, the movement with acceleration and steering.

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

## Preview

Spaceships leave their home and quickly find the first lot of resources.

![Spaceships leave home](./previews/preview-start-gif.gif)

Spaceships create a stable route to go back and forth from home to resources.

![Spaceships trace route](./previews/preview-end-gif.gif)
