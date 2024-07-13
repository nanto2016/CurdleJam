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

var in_air: bool = false
var landing: bool = false
var running: bool = false
var wall_sliding: bool = false

var looking_direction: int = -1

func _physics_process(delta):
	# Get input
	var direction: float = -int(Input.is_action_pressed("left")) + int(Input.is_action_pressed("right"))
	
	#region On Floor
	if is_on_floor():
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
			if not landing:
				if not running:
					running = true
					sprite.play("running")
			sprite.flip_h = true if looking_direction > 0 else false
		
		# deceleration
		else:
			velocity.x = move_toward(velocity.x, 0, deceleration)
			if not landing:
				sprite.play("idle")
				running = false
		
		if Input.is_action_just_pressed("jump"):
			jump()
			sprite.play("jump")
	#endregion
	
	#region Not on floor
	else:
		in_air = true
		running = false
		
		# Ledge Grab
		if is_on_wall_only():
			ledge_grab_ray.target_position.x = 20 * looking_direction
			ledge_grab_ray.force_raycast_update()
			if not ledge_grab_ray.is_colliding() and Input.is_action_just_pressed("jump"):
				ledge_grab()
				return
		
		#region Wall Jump
		left.force_raycast_update()
		if left.is_colliding():
			looking_direction = 1
			sprite.flip_h = true
			if Input.is_action_just_pressed("jump"):
				wall_jump()
				wall_sliding = false
			elif not wall_sliding:
				wall_sliding = true
				sprite.play("wall slide")
		
		else:
			right.force_raycast_update()
			if right.is_colliding():
				looking_direction = -1
				sprite.flip_h = false
				if Input.is_action_just_pressed("jump"):
					wall_jump()
					wall_sliding = false
				elif not wall_sliding:
					wall_sliding = true
					sprite.play("wall slide")
			elif wall_sliding:
				wall_sliding = false
				sprite.play("jump")
				sprite.frame = 4
				
									# CAUTION, WARNING: TO BE CHANGED
				
				push_warning("player.gd, line 107: must change sprite.frame to the frame when the sprite has arms up in the air")
				running = false
				#endregion
		
		if direction:
			looking_direction = int(direction)
			sprite.flip_h = true if looking_direction > 0 else false
		
		if direction > 0:
			velocity.x += clamp(direction * air_acceleration, 0, speed - velocity.x)
		else:
			velocity.x += clamp(direction * air_acceleration, -speed - velocity.x, 0)
		
		# deceleration
		if not direction:
			velocity.x = move_toward(velocity.x, 0, air_deceleration)
		
		velocity = Vector2(velocity.x, clamp(velocity.y + gravity * delta, -INF, wall_slide_speed if wall_sliding else INF))
	#endregion
	
	move_and_slide()


func jump():
	velocity += Vector2(0, -sqrt(2 * gravity * jump_height))


func wall_jump():
	print_rich("[color=yellow]⚠️ WALL JUMPED!!! ⚠️[/color]")
	velocity += wall_jump_direction * looking_direction


func ledge_grab():
	#ledge_grab_ray.target_position.x = 20 * looking_direction
	#ledge_grab_ray.force_raycast_update()
	#while ledge_grab_ray.is_colliding():
		#ledge_grab_ray.force_raycast_update()
	position.x -= looking_direction * 8
	velocity = Vector2(8 * looking_direction, -250)


func _on_sprite_animation_finished():
	if sprite.animation == StringName("land"):
		landing = false
