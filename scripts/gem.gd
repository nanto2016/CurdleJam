extends RigidBody2D

func _ready():
	$Sprite.play(StringName("gem" + var_to_str(randi_range(0, 5))))
	gravity_scale = 0.2


func throw(force: Vector2):
	apply_central_impulse(force)
	apply_torque_impulse(randf_range(-0.01, 0.01))


func _on_freeze_body_entered(body):
	freeze = true
