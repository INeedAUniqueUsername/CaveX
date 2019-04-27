extends RigidBody2D

# Member variables
var disabled = false


var vel_prev = Vector2()
func _integrate_forces(state):
	vel_prev = linear_velocity;
	pass

func _on_body_entered(body):
	#if body is RigidBody2D:
		#body.linear_velocity += linear_velocity;
	if body.name == "player":
		body.disable_time = 120
	if linear_velocity.length() < 90:
		queue_free()