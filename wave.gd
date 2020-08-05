extends RigidBody2D
var wave_up = load("res://wave_up.tscn")
var wave_down = load("res://wave_down.tscn")
var wave_left = load("res://wave_left.tscn")
var wave_right = load("res://wave_right.tscn")
var creator = null

var dead = false

func _ready():
	$Timer.start()

func decay():
	$anim.play('shutdown')

var vel_prev = Vector2()
var vel_prev2 = vel_prev
func _integrate_forces(state):
	vel_prev2 = vel_prev
	vel_prev = linear_velocity;
	pass

func _on_body_entered(body):
	if dead:
		return
	dead = true
	if body is RigidBody2D:		
		if self.name == 'wave_left':
			if body.name == 'player':
				var v = body.linear_velocity
				var c = vel_prev2
				#breakpoint;
		
		#Doesn't work properly if the player is moving downwards. Go figure.
		body.linear_velocity += vel_prev2.normalized() * 0.2
	if body is TileMap:
		if self.name == "wave_up" || self.name == "wave_down":
			
			var offset_y = 0;
			if self.name == "wave_up":
				offset_y = -16;
			elif self.name == "wave_down":
				offset_y = 16;
			
			var parent = get_parent()
			
			var left = wave_left.instance();
			left.position = self.position + Vector2(-8, offset_y)
			left.linear_velocity = Vector2(-120, 0)
			parent.call_deferred("add_child", left)
			
			var right = wave_right.instance()
			right.position = self.position + Vector2(8, offset_y)
			right.linear_velocity = Vector2(120, 0)
			parent.call_deferred("add_child", right)
			
			if creator != null:
				right.add_collision_exception_with(creator)
				left.add_collision_exception_with(creator)
	
	
	queue_free()
