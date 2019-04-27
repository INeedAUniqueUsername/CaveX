extends RigidBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var blast = load("res://blast.tscn")
var vel_prev = Vector2(0, 0);
func _integrate_forces(state):
	
	var lv = linear_velocity;
	if(abs(lv.length() - vel_prev.length()) / 30 > 10):
		var sources = $Blasts.get_children()
		for blast_source in sources:
			var b = blast.instance()
			var offset = blast_source.position;
			b.position = position;
			b.linear_velocity = offset * 150;
			get_parent().call_deferred("add_child", b);
		queue_free()
	else:
		vel_prev = linear_velocity;