extends Control

var level_1: PackedScene = preload("res://scenes/level_1.tscn")


func _ready():
	$Buttons.visible = false
	$Transition.visible = true


func _on_animation_player_animation_finished(anim_name):
	if anim_name == StringName("transition_in"):
		$Title.visible = true
		$AnimationPlayer.play("falling_text")
	if anim_name == StringName("falling_text"):
		$WaitBeforeButtonsAppear.start()
		$Title/BURROW/CPUParticles2D.emitting = true
	if anim_name == StringName("transition_out"):
		get_parent().add_child(level_1.instantiate())
		queue_free()


func _on_play_pressed():
	$AnimationPlayer.play("transition_out")


func _on_timer_timeout():
		$Buttons.visible = true
		$Buttons/Play/CPUParticles2D.emitting = true
