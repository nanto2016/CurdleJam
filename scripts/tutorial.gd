extends ColorRect

var level_1: PackedScene = preload("res://scenes/level_1.tscn")
var text: PackedStringArray = [
"[center]Your goal in this game is to escape this hole you fell into
with as many [color=green]GEMS[/color] as possible[/center]",
"[center]Eeach level (there's only one) has 6 [color=green]GEMS[/color] in it
press [u]E[/u] or [u]Right-Click[/u] to pick them up[/center]",
"[center]Take as many as possible with you!
Though every [color=green]GEM[/color] makes you [color=salmon]heavier[/color],
[color=salmon]slowing[/color] you down in your escape,
which can be fatal [wave]because...[/wave][/center]",
"[center]...the [color=orange]LAVA[/color] is rising![/center]",
"[center] 
 
 
How to climb:
-
[u]A[/u] and [u]D[/u] to move
-
[u]SPACE[/u] to jump
-
[u]LEFT-CLICK[/u] to [u]THROW[/u] [color=green]GEMS[/color]
-
[u]RIGHT-CLICK[/u] to [u]PICK UP[/u] [color=green]GEMS[/color][/center]",
"[center][color=goldenrod]LEDGE GRAB[/color]
Move towards a platform's edge and press [u]JUMP[/u] to [color=goldenrod]LEDGE GRAB[/color][/center]",
"[center]To cross a large gap, [u]THROW[/u] a [color=green]GEM[/color] to be lighter
then [u]PICK UP[/u] that [color=green]GEM[/color] in the air[/center]",
"[center][u]WALL JUMPING[/u]
To reach a ledge that is too high to reach with a simple jump,
Wall jump on the wall to gain a little bit of upwards velocity to then LEDGE GRAB the ledge",
"[center]For more information, you may look at the [color=red]itch.io[/color] page
It contains detailed instuctions, tips and a playthrough (if I have the time to make all of this)[/center]"]

var anim: int = 0


func _ready():
	push_warning("MAKE A PLAYTHROUGH!!!!!!")
	$CenterContainer/Text.text = text[anim]


func _on_next_pressed():
	anim += 1
	$"../UI_confirm".play()
	if anim == text.size():
		get_parent().add_child(level_1.instantiate())
		queue_free()
		return
	$CenterContainer/Text.text = text[anim]
	$Instructions.animation = StringName(var_to_str(anim))
	$Instructions.play()


func _on_next_mouse_entered():
	$"../UI_hover".play()
