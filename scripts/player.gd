extends CharacterBody2D

@export_category("Movement")

@export_group("Grounded")
# Acceleration
@export_range(10.0, 100.0, 10.0, "suffix:px/s²") var acceleration: float
# Maximum speed
@export_range(100.0, 500.0, 25.0, "suffix:px/s") var speed: float
# Deceleration
@export_range(10.0, 100.0, 10.0, "suffix:px/s²") var deceleration: float

@export_group("Aerial")
# Graity
@export_range(100, 1000, 50, "suffix:px/s²") var gravity: int
# Air acceleration
@export_range(10.0, 100.0, 10.0, "suffix:px/s²") var air_acceleration: float
## Added to velocity
@export_range(10.0, 100.0, 10.0, "suffix:px/s²") var air_deceleration: float
## Exact vertical displacement of the player when jumping, in pixels. This actually works: there are calculation made when jumping based on gravity, so whatever the gravity (even if it changes in-game) the player will jump this high
@export_range(10, 100, 5, "suffix:px") var jump_height: int
## Vector added to velocity when wall jumping
@export var wall_jump_direction: Vector2
## Max speed at which you can go while sliding on a wall
@export_range(10.0, 100.0, 5, "suffix:px/s") var wall_slide_speed: float
## How much acceleration towards the ground each Gem will it add to gravity
@export_range(1.0, 10.0, 0.1, "suffix:px/s²", "slider_only") var gem_weight: float

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var left: RayCast2D = $Left
@onready var right: RayCast2D = $Right
@onready var ledge_grab_ray: RayCast2D = $"Ledge grab"

var gem: PackedScene = preload("res://scenes/gem.tscn")

var in_air: bool = false
var landing: bool = false
var running: bool = false
var wall_sliding: bool = false
var ledge_grabbing: bool = false
var ledge_hanging: bool = false
var show_range: bool = false:
	set(value):
		show_range = value
		if value == true:
			$"Pickup range".start()
		queue_redraw()

var looking_direction: int = -1
var gems: int:
	set(value):
		gems = value
		$Sprite/GemsLeft.size.y = 16 * clampi(value, 0, 3)
		$Sprite/GemsRight.size.y = 16 * clampi(value - 3, 0, 3)
var gem_colors: Array[int] = [-1, -1, -1, -1, -1, -1]


func _ready():
	gems = 0
	sprite.stop()
	push_warning("The indicator showing the number of gems doesn't match the color of the gems picked up")


func _physics_process(delta):
	if not ledge_grabbing:
		var direction: float = -int(Input.is_action_pressed("left")) + int(Input.is_action_pressed("right"))
		var just_jumped: bool = true if Input.is_action_just_pressed("jump") else false
		
		if Input.is_action_just_pressed("throw"):
			if gems > 0:
				throw_gem()
		
		if Input.is_action_just_pressed("pickup"):
			show_range = true
			var nearby_gems: Array = $Pickup.get_overlapping_areas()
			if nearby_gems.size() > 0:
				# Pick up a gem
				gems += 1
				gem_colors[gems - 1] = nearby_gems[0].get_parent().color
				nearby_gems[0].get_parent().queue_free()
		
		if is_on_floor(): # On Floor
			if in_air:
				in_air = false
				$AnimationPlayer.play("land")
				landing = true
				running = false
			
			if wall_sliding:
				wall_sliding = false
				$AnimationPlayer.play("idle")
				running = false
			
			if direction > 0:
				velocity.x += clamp(direction * acceleration, 0, speed - velocity.x)
			else:
				velocity.x += clamp(direction * acceleration, -speed - velocity.x, 0)
			
			# animation
			if direction:
				looking_direction = int(direction)
				if not landing and not running:
						running = true
						$AnimationPlayer.play("run")
				sprite.flip_h = true if looking_direction > 0 else false
			
			# deceleration
			else:
				velocity.x = move_toward(velocity.x, 0, deceleration)
				if not landing:
					$AnimationPlayer.play("idle")
					running = false
			
			if just_jumped:
				jump()
				$AnimationPlayer.play("jump")
		
		else: # Not on floor
			running = false
			
			if direction:
				looking_direction = int(direction)
				sprite.flip_h = true if looking_direction > 0 else false
			
			#region Ledge Grab
			if is_on_wall():
				ledge_grab_ray.target_position.x = 20 * direction
				ledge_grab_ray.force_raycast_update()
				if not ledge_grab_ray.is_colliding():
					looking_direction = int(direction)
					left.force_raycast_update()
					right.force_raycast_update()
					if just_jumped and ((direction > 0 and not left.is_colliding()) or (direction < 0 and not right.is_colliding())):
						ledge_grab(int(direction))
						ledge_grabbing = true
						direction = 0
						just_jumped = false
						sprite.stop()
						wall_sliding = false
						in_air = true
						return
				else:
					$"Ledge hang".target_position.x = 20 * direction
					$"Ledge hang".force_raycast_update()
					if not $"Ledge hang".is_colliding():
						if not ledge_hanging:
							ledge_hanging = true
							velocity.y = 0
							$AnimationPlayer.stop()
							sprite.frame = 0
							sprite.animation = StringName("ledge hang")
					else:
						in_air = false
						wall_sliding = true
						sprite.animation = StringName("wall slide")
						left.force_raycast_update()
						if left.is_colliding():
							looking_direction = 1
							sprite.flip_h = true
						else:
							looking_direction = -1
						sprite.flip_h = false
			else: # Not on Wall
				in_air = true
				ledge_hanging = false
				if wall_sliding:
					wall_sliding = false
					$AnimationPlayer.play("fall")
			#endregion
			
			#region Wall Jump
			left.force_raycast_update()
			if left.is_colliding():
				if just_jumped:
					looking_direction = 1
					sprite.flip_h = true
					wall_jump()
					wall_sliding = false
					in_air = true
				
				elif is_on_wall():
					if not wall_sliding:
						wall_sliding = true
						$AnimationPlayer.stop()
						sprite.animation = StringName("wall slide")
					in_air = false
					looking_direction = 1
					sprite.flip_h = true
			
			else:
				right.force_raycast_update()
				if right.is_colliding():
					if just_jumped:
						looking_direction = -1
						sprite.flip_h = false
						wall_jump()
						wall_sliding = false
						in_air = true
					
					elif is_on_wall():
						if not wall_sliding:
							wall_sliding = true
							$AnimationPlayer.stop()
							sprite.animation = StringName("wall slide")
						in_air = false
						looking_direction = -1
						sprite.flip_h = false
				else: # Nor left nor right collided
					$"Jump buffer".force_raycast_update()
					if $"Jump buffer".is_colliding() and just_jumped:
						jump()
			#endregion
			
			if direction > 0:
				velocity.x += clamp(direction * air_acceleration, 0, speed - velocity.x)
			else:
				velocity.x += clamp(direction * air_acceleration, -speed - velocity.x, 0)
			
			# deceleration
			if not direction:
				velocity.x = move_toward(velocity.x, 0, air_deceleration)
			
			if not ledge_hanging:
				velocity = Vector2(velocity.x, clamp(velocity.y + gravity * delta + gem_weight * gems, -INF, wall_slide_speed if wall_sliding else INF))
			else:
				if just_jumped:
					ledge_grab(int(direction))
			
			if velocity.y > 0 and not wall_sliding and not sprite.animation == StringName("fall"):
				$AnimationPlayer.play("fall")
		
		move_and_slide()


func jump():
	velocity = Vector2(velocity.x, -sqrt(2 * gravity * jump_height))


func wall_jump():
	velocity += Vector2(wall_jump_direction.x * looking_direction, wall_jump_direction.y)


func ledge_grab(dir: int):
	var BREAK_OUT: int = 0
	ledge_grab_ray.force_raycast_update()
	if ledge_hanging:
		position.y -= 12
	while not ledge_grab_ray.is_colliding():
		if BREAK_OUT > 50:
			break
		BREAK_OUT += 1
		position.y += 1
		ledge_grab_ray.force_raycast_update()
	if not ledge_hanging:
		position.y -= 2
	ledge_hanging = false
	var left_or_right: String = "left" if dir < 0 else "right"
	$AnimationPlayer.play("ledge_grab_" + left_or_right)


func _on_sprite_animation_finished():
	if sprite.animation == StringName("land"):
		landing = false


# AnimatedSprite2D animations
func _on_animation_finished(anim_name: StringName):
	if anim_name.substr(0, 10) == "ledge_grab":
		global_position = sprite.global_position
		sprite.position = Vector2.ZERO
		ledge_grabbing = false
	elif anim_name == StringName("land"):
		landing = false


func throw_gem():
	var new_gem: RigidBody2D = gem.instantiate()
	new_gem.global_position = global_position
	get_parent().add_child(new_gem)
	new_gem.color = gem_colors[gems - 1]
	new_gem.update_color()
	new_gem.throw(get_local_mouse_position().limit_length(125) * 2)
	gems -= 1


func _draw():
	if show_range:
		draw_arc(Vector2.ZERO, $Pickup/Shape.shape.radius, 0, TAU, 20, Color.WHITE)


func _on_pickup_range_timeout():
	show_range = false
