extends RigidBody2D

var fuse = 30 * 0.5
var fuse_countdown = false

onready var particle = load("res://enemy.tscn")

const ANGLES = [ 0, 60, 120, 180, 240, 300 ]

func _ready():
	pass

func _on_grenade_body_entered(body):
	fuse_countdown = true

func _process(delta):
	if not fuse_countdown:
		return
		
	fuse -= 1
	if fuse <= 0: 
		for angle in ANGLES:
			var p = particle.instance()
			var pos = position
			pos.x += cos(PI * angle / 180)
			pos.y += sin(PI * angle / 180)
			p.position = pos
			get_parent().call_deferred("add_child", p)
		self.queue_free()
