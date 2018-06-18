extends KinematicBody2D

signal player_dead


var has_shield = true
var has_dash = false
var has_ice = false

enum STATES { NORMAL, DEFEND, HIT, DASH, DEAD }
const MAX_VEL = [ 130, 30 ]
const ACCEL = 10
const DECEL = 50
const DASH_VEL = 600
const DASH_DURATION = 0.08
const DASH_COOLDOWN = 0.1
const DASH_ENERGY_COST = 15
const HIT_THROWBACK = 300#700
const HIT_THROWBACK_TIME = 1.5#0.07
var TYPE = 0 # type of shield

var vel = Vector2()
var dir_nxt = 1
var anim_cur = ""
var anim_nxt = "idle"
var anim_dir_cur = ""
var anim_dir_nxt = "_RD"
var hit_timer = 0.0

var is_dead = false
var is_hit = false
var mouse_pos = Vector2()
var dash_cooldown_timer = 0

var state_cur = -1
var state_nxt = STATES.NORMAL
var is_cutscene = false



func _ready():
	game.player = self
	
	TYPE = game.gamestate.type
	$player/shield_fire.set_type( TYPE )
	
	has_shield = game.is_event( "shield" )
	has_dash = game.is_event( "dash" )
	has_ice = game.is_event( "ice" )
	if has_shield:
		$player.texture = preload( "res://player/player.png" )
		$player/shield_fire.show()
		$player/shield_fire.set_type( TYPE )
		#
	else:
		$player.texture = preload( "res://player/player_noshield.png" )
		$player/shield_fire.hide()
	pass


func set_cutscene():
	is_cutscene = true
func clear_cutscene():
	$cutscene_timer.start()
func _on_cutscene_timer_timeout():
	is_cutscene = false

func set_shield():
	$player.texture = preload( "res://player/player.png" )
	$player/shield_fire.show()
	$player/shield_fire.set_type( TYPE )
	has_shield = true
	

func _physics_process(delta):
	if is_cutscene:
		state_nxt = STATES.NORMAL
		vel *= 0
		
	if is_dead:
		state_nxt = STATES.DEAD
	elif is_hit:
		state_nxt = STATES.HIT
		# cancel dash stuff
		_dash_fsm = DASH_STATES.INITIALIZE
		#$dash_particles.emitting = false
		#$dash_particles.hide()
		dash_cooldown_timer = DASH_COOLDOWN
	
	state_cur = state_nxt
	
	match state_cur:
		STATES.NORMAL:
			_state_normal( delta )
		STATES.DEFEND:
			_state_defend( delta )
		STATES.HIT:
			_state_hit( delta )
		STATES.DASH:
			_state_dash( delta )
		STATES.DEAD:
			_state_dead( delta )
	
	# place camera target with mouse or twin stick
	if game.control_type == game.MOUSE:
		mouse_pos = get_local_mouse_position()
		$camera_target.position = ( mouse_pos / 2 ).clamped( 40 )
	else:
		var direction = Vector2(Input.get_joy_axis(0, JOY_ANALOG_RX), Input.get_joy_axis(0, JOY_ANALOG_RY)).normalized()
		if direction.length() > 0.1:
			mouse_pos = direction * 150
			$camera_target.position = ( mouse_pos / 2 ).clamped( 40 )
	
	# rotate shield, if not dashing
	if state_cur != STATES.DASH:
		$shield_collision.rotation = mouse_pos.angle()
		$damagebox.rotation = mouse_pos.angle()
	
	# dash cooldown timer
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
	





func _state_normal( delta ):
	$shield_collision/target_aim.hide()
	if game.gamestate.energy < 100:
		game.gamestate.energy += 5 * delta
	$shield_collision/CollisionShape2D.disabled = true
	$dash_collision/CollisionShape2D.disabled = true
	# cancel dash stuff
	_dash_fsm = DASH_STATES.INITIALIZE
	#$dash_particles.emitting = false
	#$dash_particles.hide()
	#dash_cooldown_timer = DASH_COOLDOWN
	if is_dead or is_hit:
		return
	if has_shield and Input.is_action_pressed( "btn_defend" ):
		# prepare defense
		$shield_collision/CollisionShape2D.disabled = false
		state_nxt = STATES.DEFEND
	# move
	vel = move_and_slide( vel )
	_player_motion( MAX_VEL[0], delta )





func _state_defend( delta ):
	$dash_collision/CollisionShape2D.disabled = true
	$shield_collision/target_aim.show()
	if is_dead or is_hit:
		$shield_collision/target_aim.hide()
		return
	if not Input.is_action_pressed( "btn_defend" ):
		$shield_collision/target_aim.hide()
		state_nxt = STATES.NORMAL
	
	# move
	vel = move_and_slide( vel )
	var dir = _player_motion( MAX_VEL[1], delta )
#	if has_dash and Input.is_action_just_pressed( "btn_dash" ) and dash_cooldown_timer <= 0:
#		if game.gamestate.energy > DASH_ENERGY_COST + 5:
#			game.gamestate.energy -= DASH_ENERGY_COST
#			state_nxt = STATES.DASH
#			_dash_fsm = DASH_STATES.INITIALIZE
#			_dash_dir = dir
#			# activate dash collision
#			dash_hit = false
#			$dash_collision/CollisionShape2D.disabled = false
#			$shield_collision/target_aim.hide()





var cur_hit_anim = ""
var nxt_hit_anim = ""
func _state_hit( delta ):
	if is_dead: return
	$shield_collision/CollisionShape2D.disabled = true
	$dash_collision/CollisionShape2D.disabled = true
	$shield_collision/target_aim.hide()
	vel *= 0.97
	if vel.x < 0:
		nxt_hit_anim = "hit_LD"
	else:
		nxt_hit_anim = "hit_RD"
	vel = move_and_slide( vel )
	hit_timer -= delta
	if nxt_hit_anim != cur_hit_anim:
		cur_hit_anim = nxt_hit_anim
		$anim.play( cur_hit_anim )
	if hit_timer <= 0:
		is_hit = false
		state_nxt = STATES.NORMAL
		anim_cur = ""
		cur_hit_anim = ""
		vel *= 0
	pass









var dash_particle_scn = preload( "res://player/dash_particle.tscn" )
enum DASH_STATES { INITIALIZE, MOVING, FINISH }
var _dash_fsm = DASH_STATES.INITIALIZE
var _dash_dir = Vector2()
var _dash_timer = 0
func _state_dash( delta ):
	if _dash_fsm == DASH_STATES.INITIALIZE:
		play_dash()
		# start motion according to dash direction
		vel = _dash_dir * DASH_VEL * 60 * delta
		vel = move_and_slide( vel )
		_dash_timer = DASH_DURATION
		_dash_fsm = DASH_STATES.MOVING
		# start the dash particles
		#$dash_particles.process_material.anim_offset = $player.frame * 0.32 / 80
		#$dash_particles.show()
		#$dash_particles.emitting = true
	elif _dash_fsm == DASH_STATES.MOVING:
		_dash_timer -= delta
		vel *= 0.99
		vel = move_and_slide( vel )
		# check for collisions or end of timer to terminate dash
		#print( get_slide_count() )
		
		# create dash particle
		var d = dash_particle_scn.instance()
		d.global_position = $player.global_position
		d.frame = $player.frame
		get_parent().add_child( d )
		
		if _dash_timer <= 0 or get_slide_count() > 0:
			_dash_fsm = DASH_STATES.FINISH
	else:
		# move back to defend state
		state_nxt = STATES.DEFEND
		# prepare for next dash
		_dash_fsm = DASH_STATES.INITIALIZE
		# set cooldown timer
		dash_cooldown_timer = DASH_COOLDOWN
		vel *= 0
		# finish dash particles
		#$dash_particles.emitting = false
		#$dash_particles.hide()
	
	if is_dead or is_hit or state_nxt != STATES.DASH:
		_dash_fsm = DASH_STATES.INITIALIZE
		#$dash_particles.emitting = false
		#$dash_particles.hide()
		dash_cooldown_timer = DASH_COOLDOWN
	pass

func _state_dead( delta ):
	vel *= 0.92
	vel = move_and_slide( vel )
	pass












func _player_motion( max_vel, delta ):
	# player motion
	var dir = Vector2()
	var is_moving = false
	if Input.is_action_pressed( "btn_left" ):
		dir.x -= 1
		is_moving = true
	if Input.is_action_pressed( "btn_right" ):
		dir.x += 1
		is_moving = true
	if Input.is_action_pressed( "btn_up" ):
		dir.y -= 1
		is_moving = true
	if Input.is_action_pressed( "btn_down" ):
		dir.y += 1
		is_moving = true
	dir = dir.normalized()
	
	var hv = vel
	var new_pos = dir * max_vel
	var accel = DECEL
	if dir.dot( hv ) > 0:
		accel = ACCEL
	vel = hv.linear_interpolate( new_pos, accel * delta )
	if vel.length() < 0.5:
		vel *= 0
	
	# change shield
	if has_ice and Input.is_action_just_pressed( "btn_shield" ):
		TYPE = 1 - TYPE # invert shield type
		$player/shield_fire.set_type( TYPE )
		game.gamestate.type = TYPE
		var x = null
		print( "exploding" )
		if TYPE == 1:
			x = preload( "res://enemies/explosion.tscn" ).instance()
		else:
			x = preload( "res://enemies/ice_explosion.tscn" ).instance()
		x.global_position = $player/shield_fire.global_position + Vector2( 0, -3 )
		#x.z_index = 3
		get_parent().add_child( x )
	
	# dash
	#print( "has dash: ", has_dash, " timer: ", dash_cooldown_timer )
	if has_dash and Input.is_action_just_pressed( "btn_fire" ) and dash_cooldown_timer <= 0 and not is_cutscene:
		if ( game.gamestate.energy > DASH_ENERGY_COST + 5 ):# and ( vel.length() > 0.1 or dir.length() > 0.1 ):
			print( "starting dash" )
			game.gamestate.energy -= DASH_ENERGY_COST
			state_nxt = STATES.DASH
			_dash_fsm = DASH_STATES.INITIALIZE
			if game.control_type == game.GAMEPAD:
				if state_cur == STATES.NORMAL:
					print( "vel: ", vel.normalized(), " dir: ", dir, " mouse: ", mouse_pos )
					if vel.length() > 0.1:
						_dash_dir = vel.normalized()
					else:
						_dash_dir = mouse_pos.normalized()
	#				elif dir.length() > 0.1:
	#					_dash_dir = dir
				else:
					_dash_dir = mouse_pos.normalized()
			else:
				_dash_dir = mouse_pos.normalized()
			# activate dash collision
			dash_hit = false
			$dash_collision/CollisionShape2D.disabled = false
			$shield_collision/target_aim.hide()
	
	
	
	
	
	var orientations = [ Vector2( 1, -1 ) / sqrt( 2 ), Vector2( 1, 1 ) / sqrt( 2 ), Vector2( -1, 1 ) / sqrt( 2 ), Vector2( -1, -1 ) / sqrt( 2 ) ]
	var orientation_strs = [ "_RU", "_RD", "_LD", "_LU" ]
	var cur_oridir = mouse_pos.normalized()
	var cur_idx = -1
	var cur_dot = -10000000.0
	for idx in range( orientations.size() ):
		var aux = cur_oridir.dot( orientations[idx] )
		if aux > cur_dot:
			cur_dot = aux
			cur_idx = idx
	anim_dir_nxt = orientation_strs[cur_idx]
	
	# animation
	if is_moving:
		if state_cur == STATES.DEFEND:
			anim_nxt = "walk"
		else:
			anim_nxt = "run"
	else:
		if state_cur == STATES.DEFEND:
			anim_nxt = "defend"
		else:
			anim_nxt = "idle"
	
	if anim_cur != anim_nxt or anim_dir_cur != anim_dir_nxt:
		anim_cur = anim_nxt
		anim_dir_cur = anim_dir_nxt
		# play animation
		if true:
			$anim.play( anim_cur + anim_dir_cur )
		else:
			$anim.play_backwards( anim_cur )
	return dir






func hit( type, dir ):
	#return # invulnerable
	if is_hit: return
	if is_dead: return
	is_hit = true
	#$dash_particles.emitting = false
	#$dash_particles.hide()
	print( "PLAYER TYPE: ", TYPE, "  HIT TYPE: ", type, " IS DEFENDING? ", ( state_cur == STATES.DEFEND ), " direction (must be <0) ", dir.dot( mouse_pos.normalized() ) )
	if type == TYPE:#type >= 0:
		if ( state_cur == STATES.DEFEND or state_cur == STATES.DASH or state_cur == STATES.HIT ) and dir.dot( mouse_pos.normalized() ) < 0:
			# todo: reduce shield energy
			return false
	
	
	game.gamestate.energy -= 50.0
	if game.camera:
		#game.camera.shake( 0.5, 20, 10 ) #game.camera.shake( 0.35, 30, 2 )
		game.camera.shake( 0.25, 60, 8 )
	if game.gamestate.energy <= 0:
		#game.gamestate.energy = 100
		is_dead = true
		state_nxt = STATES.DEAD
		$anim.play( "dead" )
		emit_signal( "player_dead" )
		vel = dir * HIT_THROWBACK
		print( "player dead ", vel )
	else:
		# prepare throwback
		hit_timer = HIT_THROWBACK_TIME
		vel = dir * HIT_THROWBACK
		
	return true




var dash_hit = false
func _on_dash_collision_area_entered(area):
	if area.get_parent() == self:
		return
	print( "dash ", area.get_parent().name )
	if dash_hit: return
	var p = area.get_parent()
	if p.is_in_group( "bullet_target" ) and p.has_method( "hit" ):
		if p.hit( TYPE, vel.normalized(), true ):
			var x = null
			if TYPE == 0:
				x = preload( "res://enemies/explosion.tscn" ).instance()
			else:
				x = preload( "res://enemies/ice_explosion.tscn" ).instance()
			x.position = position
			get_parent().add_child(x)
			dash_hit = true
			#game.camera.shake( 0.35, 60, 4 )
		
	pass # replace with function body




var walking_dust = preload( "res://player/walking_dust.tscn" )
func dust():
	var w = walking_dust.instance()
	if vel.x < 0:
		w.scale.x = -1
	w.position = position
	get_parent().add_child( w )









func play_step():
	game.play_sfx( game.STEP, 1.5 + 0.5 * rand_range( -1, 1 ) )

func play_dash():
	game.play_sfx( game.DASH, 1.0 + 0.3 * rand_range( -1, 1 ) )





