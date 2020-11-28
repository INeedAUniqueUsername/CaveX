extends RigidBody2D

export(float) var lifetime = 8

var vel_prev = Vector2()
func _integrate_forces(state):
	vel_prev = linear_velocity;
	pass
func _process(delta):
	lifetime -= delta;
	if not lifetime > 0:
		queue_free()
	
func _on_body_entered(body):
	#if body is RigidBody2D:
		#body.linear_velocity += linear_velocity;
	if body.name == "player":
		if body.disable_time > 0:
			body.kill()
		else:
			body.disable_time = 120
	if linear_velocity.length() < 90 || lifetime < 1:
		queue_free()
