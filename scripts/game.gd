extends Control


func _ready():
	pass


func _process(_delta):
	pass


func _unhandled_key_input(event):
	if event.is_action_pressed("quit"):
		get_tree().quit()
