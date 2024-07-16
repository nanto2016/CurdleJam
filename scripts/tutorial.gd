extends ColorRect

var level_1: PackedScene = preload("res://scenes/level_1.tscn")
var text: PackedStringArray = [
		"your goal in this game is to escape this hole you fell into
		with as many gems as possible",
		"each level has 6 gems in it"]

var anim: int = 0


func _on_next_pressed():
	anim += 1
	if anim == $Instructions.sprite_frames.get_animation_names().size():
		get_parent().add_child(level_1.instantiate())
		queue_free()
	$Instructions.animation = StringName(var_to_str(anim))
