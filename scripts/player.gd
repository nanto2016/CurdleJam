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

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var left: RayCast2D = $Left
@onready var right: RayCast2D = $Right

var in_air: bool = false
var landing: bool = false
var running: bool = false
var wall_sliding: bool = false

var looking_direction: int = -1

func _physics_process(delta):
	# Get input
	var direction: float = -int(Input.is_action_pressed("left")) + int(Input.is_action_pressed("right"))
	print(direction)
	
	if is_on_floor():
		print("on floor")
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
	
	# Not on floor
	else:
		print("in air")
		in_air = true
		
		if is_on_wall():
			if Input.is_action_just_pressed("jump"):
				wall_jump()
			
			wall_sliding = true
			
			sprite.play("wall slide")
			running = false
			left.force_raycast_update()
			if left.is_colliding():
				sprite.flip_h = false
			else:
				right.force_raycast_update()
				if right.is_colliding():
					sprite.flip_h = true
		
		# if not on wall
		else:
			if wall_sliding:
				wall_sliding = false
				sprite.play("idle")
				running = false
			
			if direction:
				looking_direction = int(direction)
				sprite.flip_h = true if looking_direction < 0 else false
		
		if direction > 0:
			velocity.x += clamp(direction * air_acceleration, 0, speed - velocity.x)
		else:
			velocity.x += clamp(direction * air_acceleration, -speed - velocity.x, 0)
		
		# deceleration
		if not direction:
			velocity.x = move_toward(velocity.x, 0, air_deceleration)
		
		velocity += Vector2(0, gravity) * delta
	
	print("velocity: ", velocity)
	move_and_slide()


func jump():
	print("jump")
	velocity += Vector2(0, -sqrt(2 * gravity * jump_height))


func wall_jump():
	print("wall jump")
	velocity = wall_jump_direction * looking_direction


func _on_sprite_animation_finished():
	if sprite.animation == StringName("land"):
		landing = false
