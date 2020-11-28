extends RigidBody2D
onready var bullet = load("res://Bullet/bullet.tscn")

enum State {
	LIVE, PANIC, DEAD
}

onready var down = $raycast_down
onready var right = $raycast_right
onready var left = $raycast_left
var state = State.LIVE
var shoot_countdown = 100
var player

var deathTimer = 300;


func _ready():
	player = self.owner.get_node('player')

func _process(delta):
	
	if state == State.LIVE:
		if linear_velocity.length() < 0.5 and (left.is_colliding() or right.is_colliding()) and not down.is_colliding():
			state = State.PANIC
		
		if shoot_countdown < 100:
			shoot_countdown += 1
		else:
			fire()
	elif state == State.PANIC:
		if deathTimer > 0:
			deathTimer -= 1
		else:
			state = State.DEAD
		
		if shoot_countdown < 25:
			shoot_countdown += 1
		else:
			fire()
func die():
	state = State.DEAD
	
func fire():
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
