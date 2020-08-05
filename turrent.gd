extends RigidBody2D
onready var bullet = load("res://bullet.tscn")

var shoot_countdown = 100;
var player
func _ready():
	player = self.owner.get_node('player')

func _process(delta):
	if shoot_countdown < 100:
		shoot_countdown += 1
		return
	
	shoot_countdown = 0
	var direction = (player.position - self.position).normalized()
	var b = bullet.instance()
	
	b.position = self.position + direction
	b.position.y -= 10
	b.linear_velocity = direction * 1000
	b.gravity_scale = 0
	#b.linear_velocity.x = 2000
	#b.linear_velocity.y -= 1000
	add_collision_exception_with(b)
	get_parent().call_deferred("add_child", b)
