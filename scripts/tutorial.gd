extends ColorRect

var level_1: PackedScene = preload("res://scenes/level_1.tscn")
var text: PackedStringArray = [
"[center]Your goal in this game is to escape this hole you fell into
with as many [color=green]GEMS[/color] as possible[/center]",
"[center]Eeach level has 6 [color=green]GEMS[/color] in it
press [u]E[/u] or [u]Right-Click[/u] to pick them up[/center]",
"[center]Take as many as possible with you!
Though every [color=green]GEM[/color] makes you [color=salmon]heavier[/color],
[color=salmon]slowing[/color] you down in your escape,
which can be fatal [wave]because...[/wave][/center]",
"[center]...the [color=orange]LAVA[/color] is rising![/center]"]

var anim: int = 0


func _ready():
	push_warning("Features to add if I have time: wave shader on instructions sprite; text appearing character by character;")
	$CenterContainer/Text.text = text[anim]


func _on_next_pressed():
	anim += 1
	if anim == text.size():
		get_parent().add_child(level_1.instantiate())
		queue_free()
		return
	$CenterContainer/Text.text = text[anim]
	$Instructions.animation = StringName(var_to_str(anim))
	$Instructions.play()
