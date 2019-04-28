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

func _on_bullet_collision(body):
	self.queue_free()
