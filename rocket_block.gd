extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _integrate_forces(state):
	if active:
		linear_velocity *= 1.1
	pass
	
func _on_body_entered(body):
	if body.name == "blast":
		active = true
