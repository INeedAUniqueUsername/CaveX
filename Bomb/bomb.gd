extends RigidBody2D

export var failsafe = 4
export var bounces = 5

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


func _ready():
	pass

func _on_grenade_body_entered(body):
	bounces -= 1
	if not (failsafe > 0 or bounces > 0):
		detonate()
		
func _process(delta):
	failsafe -= delta
	pass
