extends RigidBody2D

# Member variables
var disabled = false

func disable():
	if disabled:
		return
	$anim.play("shutdown")
	disabled = true

func _ready():
	$Timer.start()


func _on_body_entered(body):
	queue_free()
	if body is RigidBody2D:
		body.linear_velocity += linear_velocity;
