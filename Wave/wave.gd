extends RigidBody2D
var wave_up = load("res://Wave/wave_up.tscn")
var wave_down = load("res://Wave/wave_down.tscn")
var wave_left = load("res://Wave/wave_left.tscn")
var wave_right = load("res://Wave/wave_right.tscn")
var creator = null

var dead = false
var vel_prev = Array()

func _ready():
	
	for i in range(0, 10):
		vel_prev.push_back(linear_velocity)
	$Timer.start()

func decay():
	$anim.play('shutdown')

func _integrate_forces(state):
	vel_prev.pop_front()
	vel_prev.push_back(linear_velocity)
	pass

func _on_body_entered(body):
	if dead:
		return
	dead = true
	if body is RigidBody2D:
		var c = Vector2(0, 0)
		var name = self.name
		if name == "wave_up":
			c = Vector2(0, 1)
			print("up")
		elif name == "wave_right":
			c = Vector2(1, 0)
			print("right")
		if name == "wave_down":
			c = Vector2(0, -1)
			print("down")
		elif name == "wave_left":
			c = Vector2(-1, 0)
			print("left")
		
		#tell me the god damn value of this variable or go fuck yourself
		#go fuck yourself
		#Doesn't work properly if the player is moving downwards. Go figure.
		#update: body.linear_velocity = body.linear_velocity
		
		#breakpoint
	elif body is TileMap:
		if self.name == "wave_up" || self.name == "wave_down":
			
			var offset_y = 0
			if self.name == "wave_up":
				offset_y = -16
			elif self.name == "wave_down":
				offset_y = 16
			
			var parent = get_parent()
			
			var vel = vel_prev.front()
			var speed = vel.length()
			
			var left = wave_left.instance();
			left.position = self.position + Vector2(-8, offset_y)
			left.linear_velocity = Vector2(-speed/2, 0)
			parent.call_deferred("add_child", left)
			
			var right = wave_right.instance()
			right.position = self.position + Vector2(8, offset_y)
			right.linear_velocity = Vector2(speed/2, 0)
			parent.call_deferred("add_child", right)
			
			if creator != null:
				right.add_collision_exception_with(creator)
				left.add_collision_exception_with(creator)
	
	
	queue_free()
