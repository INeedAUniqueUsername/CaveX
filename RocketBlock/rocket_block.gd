extends RigidBody2D

var active = false
var ticks = 0;

var particle = load("res://Blast/blast.tscn")
const ANGLE_COUNT = 12
const ANGLE_INTERVAL = 360 / ANGLE_COUNT
func detonate():
	for i in range(ANGLE_COUNT):
		if rand_range(0, 2) != 2:
			var angle = i * ANGLE_INTERVAL + rand_range(0, 30)
			var p = particle.instance()
			var offset = Vector2(cos(PI * angle / 180), sin(PI * angle / 180));
			p.position = position + offset * 8
			p.linear_velocity = offset * rand_range(300, 600)
			get_parent().call_deferred("add_child", p)
	self.queue_free()

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
		detonate()
	vel_prev = lv
	
func _on_body_entered(body):
	var n = body.name
	if ("blast" in n) || ("wave" in n):
		active = true
