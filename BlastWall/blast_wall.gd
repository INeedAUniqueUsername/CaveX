extends RigidBody2D
func _on_blast_wall_body_entered(body):
	var n = body.name
	if "blast" in n:
		if (body.linear_velocity.length() > 0.0005) and (randi()%4 == 0):
			self.queue_free()
	else:
		print(n)
