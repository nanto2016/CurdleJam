extends Control

var tutorial: PackedScene = preload("res://scenes/tutorial.tscn")
@onready var ui_confirm = %"Ui Confirm"

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
		$WaitBeforeChangingScenes.start()


func _on_play_pressed():
	$AnimationPlayer.play("transition_out")
	ui_confirm.play()
	


func _on_timer_timeout():
		$Buttons.visible = true
		$Buttons/Play/CPUParticles2D.emitting = true


func _on_timer_2_timeout():
		get_parent().add_child(tutorial.instantiate())
		queue_free()



