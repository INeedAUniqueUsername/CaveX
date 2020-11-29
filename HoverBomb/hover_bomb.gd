extends RigidBody2D

var particle = load("res://Blast/blast.tscn")
const ANGLE_COUNT = 12
const ANGLE_INTERVAL = 360 / ANGLE_COUNT
func detonate():
	for i in range(ANGLE_COUNT):
		if randi()%2 != 1:
			var angle = i * ANGLE_INTERVAL + rand_range(0, 30)
			var p = particle.instance()
			var offset = Vector2(cos(PI * angle / 180), sin(PI * angle / 180));
			p.position = position + offset * 8
			p.linear_velocity = offset * rand_range(300, 600)
			get_parent().call_deferred("add_child", p)
	self.queue_free()

var ticks = 0
var vel_prev = Vector2(0, 0)

func _ready():
	vel_prev = linear_velocity
	pass

func _on_grenade_body_entered(body):
	if (vel_prev - linear_velocity).length() > 30:
		detonate()

func _process(delta):
	if $floorcast.is_colliding():
		ticks += 1
		var down = polar2cartesian(1, rotation+PI/2)
		if ticks%6 == 5 and linear_velocity.dot(down) > 16:
			var up = polar2cartesian(1, rotation-PI/2)
			
			var thrust = 16 * 24
			
			linear_velocity += up * thrust
			
			var p = particle.instance()
			p.position = position + down * 16
			p.linear_velocity = linear_velocity + down * thrust
			get_parent().call_deferred("add_child", p)
			
			p.add_collision_exception_with(self)
	
	vel_prev = linear_velocity
