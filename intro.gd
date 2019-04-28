extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _exit():
	get_tree().quit()
	pass
	
func _play():
	get_tree().change_scene("res://stage.tscn")
	pass
	
func _about():
	get_tree().change_scene("res://about.tscn")
	pass