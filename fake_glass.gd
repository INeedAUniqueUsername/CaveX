extends RigidBody2D

func on_collide(body):
	if body.get_class() == "RigidBody2D":
		if body.linear_veolcity.length() > 0.0005:
			self.queue_free()