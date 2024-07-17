extends RigidBody2D

@export_range(-1.0, 5.0, 1.0) var color: int = -1

func _ready():
	update_color()


func throw(force: Vector2):
	apply_central_impulse(force)
	add_constant_torque(randf_range(-200, 200))


func _on_freeze_body_entered(_body):
	set_deferred(StringName("freeze"), true)


func update_color():
	if color == -1:
		color = randi_range(0, 5)
	$Sprite.play(StringName("gem" + var_to_str(color)))
