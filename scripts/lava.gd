extends Area2D

var speed: float = 15.0


func _on_body_entered(body):
	if body is RigidBody2D:
		body.queue_free()
	elif body.name == "Player":
		body.queue_free()


func _physics_process(delta):
	position.y -= delta * speed
