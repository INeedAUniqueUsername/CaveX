extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(bool) var destroy = false
export(float) var interval = 0.4
export(float) var time = 0
export(int) var index = 0;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func _process(delta):
	if get_child_count() > index:
		if destroy:
			if time < interval:
				time += delta
			else:
				time = 0
				var p = get_child(index)
				index += 1
				p.get_node("Sprite").frame = 1
				p.mode = RigidBody2D.MODE_RIGID;
				p.sleeping = false
				
	else:
		#queue_free()
		pass
			
			
func destroy():
	destroy = true

func _on_Button2_on_pressed():
	pass # Replace with function body.
