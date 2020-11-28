extends RigidBody2D

export var failsafe = 4
export var bounces = 5

onready var particle = load("res://Blast/blast.tscn")

const ANGLES = [ 0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300 ]


func _ready():
	pass

func _on_grenade_body_entered(body):
	bounces -= 1
	if not (failsafe > 0 or bounces > 0):
		for angle in ANGLES:
			if rand_range(0, 2) != 2:
				angle = angle + rand_range(0, 30)
				var p = particle.instance()
				var offset = Vector2(cos(PI * angle / 180), sin(PI * angle / 180));
				p.position = position + offset * 8
				p.linear_velocity = offset * rand_range(300, 600)
				get_parent().call_deferred("add_child", p)
		self.queue_free()
func _process(delta):
	failsafe -= delta
	pass
