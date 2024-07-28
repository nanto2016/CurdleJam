extends Area2D

var speed: float = 13.0

var level_1: PackedScene = preload("res://scenes/level_1.tscn")


func _on_body_entered(body):
	if body is RigidBody2D:
		body.queue_free()
	elif body.name == "Player":
		var level: Node2D = level_1.instantiate()
		get_node("/root/Game").call_deferred("add_child", level)
		level.name = "Level 1"
		body.get_parent().queue_free()


func _physics_process(delta):
	position.y -= delta * speed
	if get_node("/root/Game/Level 1/Player"):
		if global_position.distance_to(get_node("/root/Game/Level 1/Player").global_position) > 700:
			position.y -= delta * speed
