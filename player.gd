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
var gib = load("res://Gib.tscn")

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

var wave_up = load("res://wave_up.tscn")
var wave_right = load("res://wave_right.tscn")
var wave_down = load("res://wave_down.tscn")
var wave_left = load("res://wave_left.tscn")
var bullet = load("res://bullet.tscn")
var ground_enemy = load("res://enemy.gd")
var flying_enemy = load("res://flying_enemy.gd")

var floor_h_velocity = 0.0
onready var enemy = load("res://enemy.tscn")

var disable_time = 0;

var vel_prev = Vector2();
var boost_fuel_left = 0;
var boost_fuel_max = 250;
var boosting_time = 0;
var boost_wave_interval = 6;

var shoot_cooldown = 0;

const MAX_SHOOT_COOLDOWN = 10;
var tick = 0;

# Use _input to toggle shooting mode
# So that we don't need to query it every time
func _input(event):
	if event.is_action_pressed("shoot"):
		self.shooting = true
	if event.is_action_released("shoot"):
		self.shooting = false
func boost_wave_time():
	return tick%boost_wave_interval == 0
	
func boost_wave_up():
	if boost_wave_time():
		var wave = wave_up.instance()
		var pos = position + $wave_up_source.position
		wave.position = pos
		get_parent().call_deferred("add_child", wave)
		wave.linear_velocity = Vector2(0, self.linear_velocity.y) + Vector2(0, 320)
		add_collision_exception_with(wave)
		
func boost_wave_down():
	if boost_wave_time():
		var wave = wave_down.instance()
		var pos = position + $wave_down_source.position
		wave.position = pos
		get_parent().call_deferred("add_child", wave)
		wave.linear_velocity = Vector2(0, self.linear_velocity.y) + Vector2(0, -320)
		add_collision_exception_with(wave)
		
func boost_wave_right():
	if boost_wave_time():
		var wave = wave_right.instance()
		var pos = position + $wave_right_source.position
		wave.position = pos
		get_parent().call_deferred("add_child", wave)
		wave.linear_velocity = Vector2(self.linear_velocity.x, 0) + Vector2(-320, 0)
		add_collision_exception_with(wave)
		
func boost_wave_left():
	if boost_wave_time():
		var wave = wave_left.instance()
		var pos = position + $wave_left_source.position
		wave.position = pos
		get_parent().call_deferred("add_child", wave)
		wave.linear_velocity = Vector2(self.linear_velocity.x, 0) + Vector2(320, 0)
		add_collision_exception_with(wave)
		return;
func _integrate_forces(s):
	tick += 1;
	var lv = s.get_linear_velocity()
	var step = s.get_step()
	
	var new_anim = anim
	var new_siding_left = siding_left
	
	# Get the controls
	var move_left = Input.is_action_pressed("ui_left")
	var move_right = Input.is_action_pressed("ui_right")
	var boost_up = Input.is_action_pressed("ui_up")
	var boost_down = Input.is_action_pressed("ui_down")
	var spawn = Input.is_action_pressed("spawn")
	
	if spawn:
		var e = enemy.instance()
		var p = position
		p.y = p.y - 100
		e.position = p
		get_parent().add_child(e)
	
	#Fall damage
	var vDelta = abs(lv.length() - vel_prev.length()) / 30;
	if(vDelta > 15 && vDelta < 30):
		disable_time = 90;
	elif(vDelta > 30):
		for i in range(s.get_contact_count()):
			var cc = s.get_contact_collider_object(i)
			if cc is ground_enemy or cc is flying_enemy:
				break
			else:
				mode = RigidBody2D.MODE_STATIC
				
				remove_child($CollisionPolygon2D)
				remove_child($sprite)
		
		randomize()
		for i in [ 0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330 ]:
			var g = gib.instance()
			i += rand_range(0, 30)
			g.position = position
			g.linear_velocity = Vector2(cos(i), sin(i)) * 200
			get_parent().call_deferred("add_child", g)
			pass
			
		
	if(disable_time > 0):
		disable_time -= 1;
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
	if shooting:
		if shoot_cooldown <= 0:
			shoot_cooldown = MAX_SHOOT_COOLDOWN
			var bullet_middle = bullet.instance()
			bullet_middle.position = position + $bullet_shoot.position * Vector2(-1.0 if move_left else 1.0 if move_right else 0.0, 1.0 if boost_down else -1.0 if boost_up else 0.0)
			bullet_middle.linear_velocity = Vector2(-1000 if move_left else 1000 if move_right else 0, 3000 if boost_down else -3000 if boost_up else 0)
			add_collision_exception_with(bullet_middle)
			get_parent().call_deferred("add_child", bullet_middle)
			#$sprite/smoke.restart()
			#$sound_shoot.play()
		else:
			shoot_cooldown -= 1
		
	if found_floor:
		airborne_time = 0.0
	else:
		airborne_time += step # Time it spent in the air
	
	var on_floor = airborne_time < MAX_FLOOR_AIRBORNE_TIME


	#The player can boost up
	#The player must have high fuel to begin boosting
	#If the player is already boosting and low on fuel, we let them continue
	if((boost_up || boost_down) && disable_time == 0 && boost_fuel_left > 60 || (boost_fuel_left > 0 && boosting_time > 0)):
		
		#Acceleration from boosting
		var accel = 30 * 1
		var fuel_used = 2;
		if(boosting_time == 0):
			fuel_used = 3;
		
		var boosted = false;
		
		if boost_up:
			#Positive is down
			if lv.y/30 > -8:
				#Decrement speed until we reach max ascent speed at 4 pixels
				lv.y -= accel
				#boost_fuel_left -= fuel_used;
				boosted = true;
				boost_wave_up()
		if boost_down:
			if lv.y/30 < 4:
				#Accelerate down
				lv.y += accel
				#boost_fuel_left -= fuel_used
				boosted = true;
				boost_wave_down()
			elif lv.y/30 > 4:
				#Decrement speed until we reach max ascent speed at 4 pixels
				lv.y -= accel
				#boost_fuel_left -= fuel_used;
				boosted = true;
		boosting_time += 1;
		
		#If we use both boosts simultaneously, then some fuel is free
		if boosted: boost_fuel_left -= fuel_used
	if boost_fuel_left < boost_fuel_max && !(boost_up || boost_down):
		if on_floor:
			boost_fuel_left += 3;
		else:
			boost_fuel_left += 1;
		boosting_time = 0;
	
	if(disable_time > 0):
		new_anim = "disabled"
	elif !(boost_up || boost_down || move_left || move_right):
		new_anim = "idle"
	elif(boost_up):
		new_anim = "up"
	elif(boost_down):
		new_anim = "down"
	elif(move_left):
		new_anim = "left"
	elif(move_right):
		new_anim = "right"
	
	if on_floor:
		# Process logic when character is on floor
		if disable_time == 0 && move_left and not move_right:
			if lv.x > -WALK_MAX_VELOCITY:
				lv.x -= WALK_ACCEL * step
			boost_wave_left()
				
		elif disable_time == 0 && move_right and not move_left:
			if lv.x < WALK_MAX_VELOCITY:
				lv.x += WALK_ACCEL * step
			boost_wave_right()
				
		else:
			var xv = abs(lv.x)
			xv -= WALK_DEACCEL * step
			if xv < 0:
				xv = 0
			lv.x = sign(lv.x) * xv
		
	else:
		# Process logic when the character is in the air
		if move_left and not move_right && disable_time == 0:
			if lv.x > -WALK_MAX_VELOCITY:
				lv.x -= AIR_ACCEL * step
				boost_wave_left()
		elif move_right and not move_left && disable_time == 0:
			if lv.x < WALK_MAX_VELOCITY:
				lv.x += AIR_ACCEL * step
				boost_wave_right()
		#else:
			
			#var xv = abs(lv.x)
			#xv -= AIR_DEACCEL * step
			#if xv < 0:
			#	xv = 0
			#lv.x = sign(lv.x) * xv
	
	# Change animation
	if new_anim != anim:
		anim = new_anim
		$anim.play(anim)
	
	# Apply floor velocity
	if found_floor:
		floor_h_velocity = s.get_contact_collider_velocity_at_position(floor_index).x
		lv.x += floor_h_velocity
	
	# Finally, apply gravity and set back the linear velocity
	lv += s.get_total_gravity() * step
	s.set_linear_velocity(lv)
