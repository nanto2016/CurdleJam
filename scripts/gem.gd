extends CharacterBody2D

@export var gravity: float = 980
var angular_velocity: float


func _ready():
	$Sprite.play(StringName("gem" + var_to_str(randi_range(0, 5))))


func throw(force: Vector2):
	velocity = force
	angular_velocity = randf_range(-0.5, 0.5)


func _physics_process(delta):
	rotate(angular_velocity)
	velocity.y += gravity * delta
	move_and_slide()
