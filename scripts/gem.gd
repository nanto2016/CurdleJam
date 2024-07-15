extends RigidBody2D

func _ready():
	$Sprite.play(StringName("gem" + var_to_str(randi_range(0, 5))))


func throw(force: Vector2):
	apply_central_impulse(force)
	add_constant_torque(randf_range(-200, 200))


func _on_freeze_body_entered(_body):
	set_deferred(StringName("freeze"), true)
	print("FROZE A GEM")
