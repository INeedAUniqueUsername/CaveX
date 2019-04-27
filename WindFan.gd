extends Node2D

export(PackedScene) var wind
export(Vector2) var velocity
var tick = 0;
export(float) var interval = 0.5
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	tick += delta;
	if(tick > interval):
		tick = 0;
		var w = wind.instance()
		w.position = position
		w.linear_velocity = velocity
		get_parent().call_deferred("add_child", w)
		
	