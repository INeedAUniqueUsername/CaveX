extends RigidBody2D
func _on_fake_glass_body_entered(body):
	if body.get_class() == "RigidBody2D":
		if body.linear_velocity.length() > 0.0005:
			self.queue_free()
