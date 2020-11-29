extends RigidBody2D

export(PackedScene) var ammo = load("res://Grenade/grenade.tscn")

var tick = 0

const SHOOT_START = 360
const SHOOT_END = 420

export var angle_min = 30
export var angle_max = 60
export var throw_speed = 60 * 10

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

func _on_grenadier_body_entered(node):
	#breakpoint
	#self.queue_free()
	pass

func _init():
	randomize();

#func _on_timer_timeout():
#	queue_free()
var vel_prev = Vector2(0, 0);
func _process(delta):
	tick += 1
	if tick >= SHOOT_START:
		if tick%30 == 0:
			var g = ammo.instance()
			var angle = rand_range(angle_min * PI / 180, angle_max * PI / 180)
			var pos = self.position
			pos.x += cos(angle) * 8
			pos.y += -sin(angle) * 8
			g.position = pos
			g.linear_velocity = Vector2(cos(angle) * throw_speed, -sin(angle) * throw_speed)
			get_parent().call_deferred("add_child", g)
			add_collision_exception_with(g)
		if tick >= SHOOT_END:
			tick = 0;
		
	
	var lv = linear_velocity;
	#Fall damage
	if(abs(lv.length() - vel_prev.length()) / 30 > 15):
		detonate()
	vel_prev = lv;
