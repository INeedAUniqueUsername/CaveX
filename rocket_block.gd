extends RigidBody2D

const ANGLES = [ 0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300 ]
onready var particle = load("res://Blast/blast.tscn")
var active = false
var ticks = 0;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
var vel_prev = Vector2(0,0)
func _integrate_forces(state):
	if active:
		linear_velocity += 20 * polar2cartesian(1, rotation-PI/2)
		ticks += 1
		if ticks%5 == 4:
			var p = particle.instance()
			var offset = polar2cartesian(1, rotation + PI/2)
			p.position = position + offset * 30
			p.linear_velocity = linear_velocity + offset * 150
			p.add_collision_exception_with(self)
			get_parent().call_deferred("add_child", p)
			
			
		
	var lv = linear_velocity
	#Explode on impact
	var vDelta = abs(lv.length() - vel_prev.length()) / 30;
	if(vDelta > 10):
		for angle in ANGLES:
			if rand_range(0, 2) != 2:
				angle = angle + rand_range(0, 30)
				var p = particle.instance()
				var offset = Vector2(cos(PI * angle / 180), sin(PI * angle / 180));
				p.position = position + offset * 8
				p.linear_velocity = offset * rand_range(30*15, 30*30)
				get_parent().call_deferred("add_child", p)
		queue_free()
	vel_prev = lv
	
func _on_body_entered(body):
	if body.name == "blast" || "wave" in body.name:
		active = true
