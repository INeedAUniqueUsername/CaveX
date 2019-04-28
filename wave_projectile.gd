extends RigidBody2D
var wave_up = load("res://wave_up.tscn")
var wave_down = load("res://wave_down.tscn")
var wave_left = load("res://wave_left.tscn")
var wave_right = load("res://wave_right.tscn")
# Member variables
var disabled = false

func disable():
	if disabled:
		return
	$anim.play("shutdown")
	disabled = true

func _ready():
	$Timer.start()

var vel_prev = Vector2()
var vel_prev2 = vel_prev
func _integrate_forces(state):
	vel_prev2 = vel_prev
	vel_prev = linear_velocity;
	pass

func _on_body_entered(body):
	if body is RigidBody2D:
		body.linear_velocity +=  vel_prev2;
	if body is TileMap:
		if self.name == "wave_up" || self.name == "wave_down":
			
			var offset_y = 0;
			if self.name == "wave_up":
				offset_y = -16;
			elif self.name == "wave_down":
				offset_y = 16;
			
			var left = wave_left.instance();
			left.position = self.position + Vector2(-8, offset_y)
			left.linear_velocity = Vector2(-120, 0)
			add_collision_exception_with(get_parent())
			
			var right = wave_right.instance()
			right.position = self.position + Vector2(8, offset_y)
			right.linear_velocity = Vector2(120, 0)
			get_parent().call_deferred("add_child", left)
			get_parent().call_deferred("add_child", right)
			add_collision_exception_with(get_parent())
	queue_free()
