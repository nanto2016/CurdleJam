extends Control

var tutorial: PackedScene = preload("res://scenes/tutorial.tscn")


func _ready():
	var tween: Tween = create_tween()
	tween.tween_property($"../Falling", "volume_db", 0, 3.0)
	
	$Buttons.visible = false
	$Transition.visible = true


func _on_animation_player_animation_finished(anim_name):
	if anim_name == StringName("transition_in"):
		$Title.visible = true
		$AnimationPlayer.play("falling_text")
	if anim_name == StringName("falling_text"):
		$WaitBeforeButtonsAppear.start()
		$Title/BURROW/CPUParticles2D.emitting = true
		$"../TextFall".play()
	if anim_name == StringName("transition_out"):
		$"../SceneTransition".play()
		var tween: Tween = create_tween()
		tween.tween_property($"../Falling", "volume_db", -80.0, 1.0)
		tween.finished.connect(_on_tween_finished)


func _on_play_pressed():
	$AnimationPlayer.play("transition_out")
	$"../UI_confirm".play()


func _on_timer_timeout():
		$Buttons.visible = true
		$Buttons/Play/CPUParticles2D.emitting = true


func _on_tween_finished():
		$"../Falling".playing = false
		get_parent().add_child(tutorial.instantiate())
		queue_free()


func _on_play_mouse_entered():
	$"../UI_hover".play()
