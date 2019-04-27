extends RigidBody2D

onready var ammo = load("res://grenade.tscn")

var tick = 0

const SHOOT_THRESHOLD = 100

export var angle_min = 30
export var angle_max = 60
export var throw_speed = 60 * 10

var RAND = RandomNumberGenerator.new()

func _on_grenadier_body_entered(node):
	#breakpoint
	#self.queue_free()
	pass

#func _on_timer_timeout():
#	queue_free()

func _process(delta):
	tick += 1
	if tick >= SHOOT_THRESHOLD:
		tick = 0
		var g = ammo.instance()
		var angle = RAND.randf_range(angle_min * PI / 180, angle_max * PI / 180)
		var pos = self.position
		pos.x += cos(angle) * 8
		pos.y += -sin(angle) * 8
		g.position = pos
		g.linear_velocity = Vector2(cos(angle) * throw_speed, -sin(angle) * throw_speed)
		get_parent().call_deferred("add_child", g)
		
		