extends RigidBody2D

# Character Demo, written by Juan Linietsky.
#
# Implementation of a 2D Character controller.
# This implementation uses the physics engine for
# controlling a character, in a very similar way
# than a 3D character controller would be implemented.
#
# Using the physics engine for this has the main
# advantages:
# -Easy to write.
# -Interaction with other physics-based objects is free
# -Only have to deal with the object linear velocity, not position
# -All collision/area framework available
# 
# But also has the following disadvantages:
#  
# -Objects may bounce a little bit sometimes
# -Going up ramps sends the chracter flying up, small hack is needed.
# -A ray collider is needed to avoid sliding down on ramps and  
#   undesiderd bumps, small steps and rare numerical precision errors.
#   (another alternative may be to turn on friction when the character is not moving).
# -Friction cant be used, so floor velocity must be considered
#  for moving platforms.

# Member variables
var anim = ""
var siding_left = false
var jumping = false
var stopping_jump = false
var shooting = false

var WALK_ACCEL = 800.0
var WALK_DEACCEL = 800.0
var WALK_MAX_VELOCITY = 200.0
var AIR_ACCEL = 200.0
var AIR_DEACCEL = 200.0
var JUMP_VELOCITY = 460
var STOP_JUMP_FORCE = 900.0

var MAX_FLOOR_AIRBORNE_TIME = 0.15

var airborne_time = 1e20
var shoot_time = 1e20

var MAX_SHOOT_POSE_TIME = 0.3

var bullet = preload("res://bullet.tscn")

var floor_h_velocity = 0.0
onready var enemy = load("res://enemy.tscn")

var disable_time = 0;

var vel_prev = Vector2();
var boost_fuel_left = 0;
var boost_fuel_max = 120;
var boosting_time = 0;

func _integrate_forces(s):
	var lv = s.get_linear_velocity()
	var step = s.get_step()
	
	var new_anim = anim
	var new_siding_left = siding_left
	
	# Get the controls
	var move_left = Input.is_action_pressed("ui_left")
	var move_right = Input.is_action_pressed("ui_right")
	var boost_up = Input.is_action_pressed("ui_up")
	var boost_down = Input.is_action_pressed("ui_down")
	var shoot = Input.is_action_pressed("shoot")
	var spawn = Input.is_action_pressed("spawn")
	
	if spawn:
		var e = enemy.instance()
		var p = position
		p.y = p.y - 100
		e.position = p
		get_parent().add_child(e)
	
	if(abs(lv.length() - vel_prev.length()) / 30 > 30):
		queue_free()
	vel_prev = lv;
	
	
	# Deapply prev floor velocity
	lv.x -= floor_h_velocity
	floor_h_velocity = 0.0
	
	# Find the floor (a contact with upwards facing collision normal)
	var found_floor = false
	var floor_index = -1
	
	for x in range(s.get_contact_count()):
		var ci = s.get_contact_local_normal(x)
		if ci.dot(Vector2(0, -1)) > 0.6:
			found_floor = true
			floor_index = x
	
	
	
	# A good idea when implementing characters of all kinds,
	# compensates for physics imprecision, as well as human reaction delay.
	if shoot and not shooting:
		shoot_time = 0
		var bi = bullet.instance()
		var ss
		if siding_left:
			ss = -1.0
		else:
			ss = 1.0
		var pos = position + $bullet_shoot.position * Vector2(ss, 1.0)
		
		bi.position = pos
		get_parent().add_child(bi)
		
		bi.linear_velocity = Vector2(800.0 * ss, -80)
		
		$sprite/smoke.restart()
		$sound_shoot.play()
		
		add_collision_exception_with(bi) # Make bullet and this not collide
	else:
		shoot_time += step
	if found_floor:
		airborne_time = 0.0
	else:
		airborne_time += step # Time it spent in the air
	
	var on_floor = airborne_time < MAX_FLOOR_AIRBORNE_TIME


	#The player can boost up
	#The player must have high fuel to begin boosting
	#If the player is already boosting and low on fuel, we let them continue
	if(boost_fuel_left > 60 || (boost_fuel_left > 0 && boosting_time > 0) && (boost_up || boost_down)):
		
		#Acceleration from boosting
		var accel = 30 * 1
		var fuel_used = 2;
		if(boosting_time == 0):
			fuel_used = 3;
		
		if boost_up:
			#Positive is down
			if lv.y/30 > -8:
				#Decrement speed until we reach max ascent speed at 4 pixels
				lv.y -= accel
				boost_fuel_left -= fuel_used;
		if boost_down:
			if lv.y/30 < 4:
				#Accelerate down
				lv.y += accel
				boost_fuel_left -= fuel_used;
		boosting_time += 1;
	if boost_fuel_left < boost_fuel_max && !(boost_up || boost_down):
		if on_floor:
			boost_fuel_left += 3;
		else:
			boost_fuel_left += 1;
		boosting_time = 0;
	
	
	if on_floor:
		# Process logic when character is on floor
		if move_left and not move_right:
			if lv.x > -WALK_MAX_VELOCITY:
				lv.x -= WALK_ACCEL * step
		elif move_right and not move_left:
			if lv.x < WALK_MAX_VELOCITY:
				lv.x += WALK_ACCEL * step
		else:
			var xv = abs(lv.x)
			xv -= WALK_DEACCEL * step
			if xv < 0:
				xv = 0
			lv.x = sign(lv.x) * xv
		
		# Check siding
		if lv.x < 0 and move_left:
			new_siding_left = true
		elif lv.x > 0 and move_right:
			new_siding_left = false
		if jumping:
			new_anim = "jumping"
		elif abs(lv.x) < 0.1:
			if shoot_time < MAX_SHOOT_POSE_TIME:
				new_anim = "idle_weapon"
			else:
				new_anim = "idle"
		else:
			if shoot_time < MAX_SHOOT_POSE_TIME:
				new_anim = "run_weapon"
			else:
				new_anim = "run"
	else:
		# Process logic when the character is in the air
		if move_left and not move_right:
			if lv.x > -WALK_MAX_VELOCITY:
				lv.x -= AIR_ACCEL * step
		elif move_right and not move_left:
			if lv.x < WALK_MAX_VELOCITY:
				lv.x += AIR_ACCEL * step
		#else:
			
			#var xv = abs(lv.x)
			#xv -= AIR_DEACCEL * step
			#if xv < 0:
			#	xv = 0
			#lv.x = sign(lv.x) * xv
		
		if lv.y < 0:
			if shoot_time < MAX_SHOOT_POSE_TIME:
				new_anim = "jumping_weapon"
			else:
				new_anim = "jumping"
		else:
			if shoot_time < MAX_SHOOT_POSE_TIME:
				new_anim = "falling_weapon"
			else:
				new_anim = "falling"
	
	# Update siding
	if new_siding_left != siding_left:
		if new_siding_left:
			$sprite.scale.x = -1
		else:
			$sprite.scale.x = 1
		
		siding_left = new_siding_left
	
	# Change animation
	if new_anim != anim:
		anim = new_anim
		$anim.play(anim)
	
	shooting = shoot
	
	# Apply floor velocity
	if found_floor:
		floor_h_velocity = s.get_contact_collider_velocity_at_position(floor_index).x
		lv.x += floor_h_velocity
	
	# Finally, apply gravity and set back the linear velocity
	lv += s.get_total_gravity() * step
	s.set_linear_velocity(lv)
