extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(ev):
	if Input.is_key_pressed(KEY_X):
		_exit()
	elif Input.is_key_pressed(KEY_Y):
		_play()
	elif Input.is_key_pressed(KEY_Z):
		_about()
	
func _exit():
	get_tree().quit()
	pass
	
func _play():
	get_tree().change_scene("res://stage.tscn")
	pass
	
func _about():
	get_tree().change_scene("res://About.tscn")
	pass
