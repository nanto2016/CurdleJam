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
# Air deceleration
@export_range(10.0, 100.0, 10.0, "suffix:px/s²") var air_deceleration: float
# Jump height
@export_range(10, 100, 5, "suffix:px") var jump_height: int
# Wall jump
@export var wall_jump_direction: Vector2
# Wall slide
@export_range(10.0, 100.0, 5, "suffix:px/s") var wall_slide_speed: float

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var left: RayCast2D = $Left
@onready var right: RayCast2D = $Right
@onready var ledge_grab_ray: RayCast2D = $"Ledge grab"

var gem: PackedScene = preload("res://scenes/gem.tscn")

var in_air: bool = false
var landing: bool = false
var running: bool = false
var wall_sliding: bool = false
var hanging: bool = false
var ledge_grabbing: bool = false

var looking_direction: int = -1
var gems: int

func _physics_process(delta):
	if not ledge_grabbing:
		var direction: float = -int(Input.is_action_pressed("left")) + int(Input.is_action_pressed("right"))
		var just_jumped: bool = true if Input.is_action_just_pressed("jump") else false
		
		if Input.is_action_just_pressed("throw"):
			if gems > 0:
				var new_gem: CharacterBody2D = gem.instantiate()
				add_child(new_gem)
				new_gem.throw(Vector2(100, 0))
				gems -= 1
		
		if is_on_floor(): # On Floor
			if in_air:
				in_air = false
				sprite.play("land")
				landing = true
				running = false
			
			if wall_sliding:
				wall_sliding = false
				sprite.play("idle")
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
						sprite.play("run")
				sprite.flip_h = true if looking_direction > 0 else false
			
			# deceleration
			else:
				velocity.x = move_toward(velocity.x, 0, deceleration)
				if not landing:
					sprite.play("idle")
					running = false
			
			if just_jumped:
				jump()
				sprite.play("jump")
		
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
						print(int(direction))
						ledge_grab(int(direction))
						ledge_grabbing = true
						direction = 0
						just_jumped = false
						sprite.stop()
						wall_sliding = false
						in_air = true
						return
					else:
						wall_sliding = false
						if not hanging:
							hanging = true
							sprite.play("ledge hang")
				else:
					in_air = false
					wall_sliding = true
					sprite.play("wall slide")
					left.force_raycast_update()
					if left.is_colliding():
						looking_direction = 1
						sprite.flip_h = true
					else:
						looking_direction = -1
						sprite.flip_h = false
			else: # Not on Wall
				in_air = true
				if wall_sliding:
					wall_sliding = false
					sprite.play("fall")
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
						sprite.play("wall slide")
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
							sprite.play("wall slide")
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
			
			velocity = Vector2(velocity.x, clamp(velocity.y + gravity * delta, -INF, wall_slide_speed if wall_sliding else INF))
			
			if velocity.y > 0 and not wall_sliding and not sprite.animation == StringName("fall"):
				sprite.play("fall")
		
		move_and_slide()


func jump():
	velocity = Vector2(velocity.x, -sqrt(2 * gravity * jump_height))


func wall_jump():
	velocity += Vector2(wall_jump_direction.x * looking_direction, wall_jump_direction.y)


func ledge_grab(dir: int):
	ledge_grab_ray.force_raycast_update()
	while not ledge_grab_ray.is_colliding():
		position.y += 1
		ledge_grab_ray.force_raycast_update()
	position.y -= 2
	var left_or_right: String = "left" if dir < 0 else "right"
	$AnimationPlayer.play("ledge_grab_" + left_or_right)


func _on_sprite_animation_finished():
	if sprite.animation == StringName("land"):
		landing = false


# AnimatedSprite2D animations
func _on_animation_finished():
	if sprite.animation == StringName("land"):
		landing = false


func _on_ledge_grab_animation_finished(_anim_name):
	global_position = sprite.global_position
	sprite.position = Vector2.ZERO
	ledge_grabbing = false
