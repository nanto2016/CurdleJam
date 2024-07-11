extends Control

var screen_shake: bool = false
var amplitude: int = 2
var main_menu: PackedScene = preload("res://scenes/main_menu.tscn")


func _ready():
	$Hole.visible = false


func _on_animation_finished(anim_name):
	# After having walked for 3 seconds, stand still
	if anim_name == StringName("intro"):
		$Player.play("idle")
		$WaitBeforeStartingScreenShake.start()


func _on_timer_1_timeout():
	# Just waited 0.5s after standing still, now activate screen shake
	screen_shake = true
	$WaitBeforeEndingScreenShake.start()


func _on_timer_2_timeout():
	# Screen has been shaking for 0.5s, now collapse ground
	screen_shake = false
	
	$Hole.visible = true
	$Hole/GPUParticles2D.emitting = true
	$AnimationPlayer.play("fall")
	
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property($Transition, "size", Vector2(1152, 648), 2)
	
	$WaitBeforeChangingScenes.start()


func _on_timer_3_timeout():
	# 2.01s after ground collapsed, change scenes
	get_parent().add_child(main_menu.instantiate())
	queue_free()


func _process(_delta):
	if screen_shake:
		position = Vector2(randf_range(-amplitude, amplitude),
				randf_range(-amplitude, amplitude))
