extends KinematicBody2D
signal died

enum STATES { SPAWN, IDLE, HUNT, FIRE, HIT, DEAD, HIT_COOLDOWN }

var TYPE = 0
var BOXWIDTH = 196
var MAX_VEL = 80
var HUNT_RANGE = 400
var FIRE_RANGE = 150
var FIRE_INTERVAL = 4
var FIRE_THROWBACK = 300
var FIRE_THROWBACK_TIME = 0.02
var HIT_THROWBACK = 200
var HIT_THROWBACK_TIME = 1.5#0.05
var DIR_INTERVAL = 0.2
var HIT_PLAYER_COOLDOWN_TIME = 1.3


var energy = 100
var dir_cur = 1
var dir_nxt = 1
var dir_timer = DIR_INTERVAL
var hit_cooldown_timer = 0

var state_cur = -1
var state_nxt = STATES.SPAWN
var is_hit = false
var is_dead = false
var can_fire = false
var fire_timer = 0.5
var hit_timer = 0

var vel = Vector2()

var anim_cur = ""
var anim_nxt = "spawn"

func _ready():
	call_deferred( "set_sprite_viewport_texture" )
	connect( "died", game.main.get_node( "hud_layer/hud/bonus_counter" ), "enemy_dead" )

func set_sprite_viewport_texture():
	$effect.texture = $Viewport.get_texture()

func update_particles():
	$effect.region_rect = Rect2( global_position - BOXWIDTH / 2.0 * Vector2( 1, 1 ), BOXWIDTH * Vector2( 1, 1 ) )
	$Viewport/particles.global_position = global_position
	#$Viewport/explode.global_position = global_position

func update_states( delta ):
	if is_hit:
		state_nxt = STATES.HIT
	#if state_cur != state_nxt:
	#	print( name, " state: ", state_nxt )
	
	vel = move_and_slide( vel )
	
	
	state_cur = state_nxt
	match state_cur:
		STATES.SPAWN:
			_state_spawn( delta )
		STATES.IDLE:
			_state_idle( delta )
		STATES.HUNT:
			_state_hunt( delta )
		STATES.FIRE:
			_state_fire( delta )
		STATES.HIT:
			_state_hit( delta )
		STATES.DEAD:
			_state_dead( delta )
		STATES.HIT_COOLDOWN:
			_state_hit_cooldown( delta )
	
	if not can_fire:
		fire_timer -= delta
		if fire_timer <= 0:
			can_fire = true
	
	
	# update direction
	if state_nxt != STATES.FIRE and state_nxt != STATES.HIT:
	#	print( "changing dir" )
		if vel.x > 0:
			dir_nxt = 1
		elif vel.x < 0:
			dir_nxt = -1
	#if state_nxt == STATES.FIRE or state_nxt == STATES.HIT:
	#	dir_nxt = dir_cur
	
	if dir_cur != dir_nxt:
		if dir_timer > 0:
			dir_timer -= delta
			if dir_timer <= 0:
				dir_cur = dir_nxt
				dir_timer = DIR_INTERVAL
				$rotate.scale.x = dir_cur
	
	if anim_nxt != anim_cur:
		anim_cur = anim_nxt
		$anim.play( anim_cur )




func _state_spawn( delta ):
	if is_hit or is_dead:
		$hitbox/CollisionShape2D.disabled = false
		return
	$hitbox/CollisionShape2D.disabled = true
	
	pass
func _finished_spawn():
	$hitbox/CollisionShape2D.disabled = false
	state_nxt = STATES.IDLE





var player_seen = false
func _state_idle( delta ):
	if is_hit or is_dead:
		return
	anim_nxt = "idle"
	vel *= 0.95
	if game.player != null and game.player.is_dead: return
	# search for player
	var player_dist = game.player.global_position - global_position
	if player_dist.length() < HUNT_RANGE and ( player_seen or _player_in_sight() ):
		state_nxt = STATES.HUNT
		player_seen = true
	pass




func _state_hunt( delta ):
	if is_hit or is_dead:
		return
	if game.player == null:
		return
	elif game.player.is_dead:
		state_nxt = STATES.IDLE
		return
	var player_dist = ( game.player.global_position - global_position ).length()
	
	if not _player_in_sight():
		if player_dist < HUNT_RANGE:
			# navigate towards player
			var n = _navigate_towards( delta )
			if n == null:
				# no path to player
				state_nxt = STATES.IDLE
			else:
				var a = _steer_avoid()
				vel += ( n + a ) * delta
				vel = vel.clamped( MAX_VEL )
			pass
		else:
			state_nxt = STATES.IDLE
	else:
		if player_dist < FIRE_RANGE and can_fire:
			_start_fire( delta )
		elif player_dist < HUNT_RANGE:
			# move towards player
			var s = _steer_towards( game.player.global_position )
			var a = _steer_avoid()
			vel += ( s + a ) * delta
			vel = vel.clamped( MAX_VEL )
		else:
			state_nxt = STATES.IDLE
	pass







var _fire_timer = 0
var _started_fire_throwback = false
#var _fire_dir = Vector2()
func _start_fire( delta ):
	can_fire = false
	vel *= 0
	#var player_dist = game.player.global_position - global_position
	#var _fire_dir = player_dist.normalized()
	# create bullet
	_started_fire_throwback = false
	var b = create_bullet( game.player.global_position - global_position )
	b.connect( "motion_started", self, "_on_bullet_motion_started" )
	# throwback settings
	_fire_timer = FIRE_THROWBACK_TIME
	state_nxt = STATES.FIRE
	fire_timer = FIRE_INTERVAL
	
	

func _on_bullet_motion_started( b ):
	var playerpos = _player_future_pos( \
			game.player.position, \
			game.player.vel, position, b.MAX_VEL )
	var _fire_dir = ( playerpos - position ).normalized()
	b.set_dir( _fire_dir )
	b.activate()
	b.disconnect( "motion_started", self, "_on_bullet_motion_started" )
	if is_hit or is_dead:
		return
	_started_fire_throwback = true
	# throwback
	vel = -_fire_dir * FIRE_THROWBACK# * 60 * get_physics_process_delta_time()
	#print( vel , " ", _fire_dir )
	
	
	
func _state_fire( delta ):
	if is_hit or is_dead:
		return
	if not _started_fire_throwback: return
	vel *= 0.95
	_fire_timer -= delta
	if _fire_timer <= 0:
		vel *= 0
		state_nxt = STATES.IDLE




func _state_hit( delta ):
	$hitbox/CollisionShape2D.disabled = true
	vel *= 0.95
	hit_timer -= delta
	if hit_timer <= 0:
		is_hit = false
		state_nxt = STATES.HIT_COOLDOWN
		hit_cooldown_timer = HIT_PLAYER_COOLDOWN_TIME
		$hitbox/CollisionShape2D.disabled = false
	pass



func _state_dead( delta ):
	pass






func _state_hit_cooldown( delta ):
	$hitbox/CollisionShape2D.disabled = true
	if is_hit or is_dead:
		$hitbox/CollisionShape2D.disabled = false
		return
	vel *= 0.95
	hit_cooldown_timer -= delta
	if hit_cooldown_timer <= 0:
		$hitbox/CollisionShape2D.disabled = false
		state_nxt = STATES.IDLE





func _player_in_sight():
	if game.player == null: return false
	var space_state = get_world_2d().direct_space_state
	#var player_dir = game.player.global_position
	var result = space_state.intersect_ray( global_position, game.player.global_position, \
		[ self, $avoid_area, $damagebox, $hitbox, game.player.get_node( "damagebox" ) ], 1 + 4 )
	if result.empty():
		#print( "player on sight" )
		return true
	return false

func _steer_towards( target ):
	var desired_vel = MAX_VEL * ( target - position ).normalized()
	var steering_force = desired_vel - vel
	return steering_force

func _steer_avoid():
	var enemies = $avoid_area.get_overlapping_areas()
	var avoid_force = Vector2()
	for z in enemies:
		if z == self: continue
		var avoid_direction = position - z.get_parent().position
		var inverse_dist = 60 / max( avoid_direction.length(), 1 )
		avoid_force += avoid_direction.normalized() * inverse_dist * 100
	avoid_force = avoid_force.clamped( 30 )
	return avoid_force


var prv_nav_target = null
var nav_timer = 0
var NAV_INTERVAL = 1
func _navigate_towards( delta ):
	if game.navigation == null: return null
	nav_timer -= delta
	if nav_timer <= 0:
		# ask navigation if there is a path to the player
		var path = game.navigation.get_simple_path( position, game.player.position, true )
		#print( "nav: ", path )
		if path.size() < 2: return null
		prv_nav_target = path[1]
		nav_timer = NAV_INTERVAL
		return _steer_towards( path[1] )
	else:
		return _steer_towards( prv_nav_target )






func _player_future_pos( p0, v0, p, v ):
	var vL = v0.length()
	if vL < 1:
		return p0
	var dT = ( p0 - p ).length() / v # time to arrive at target
	dT = dT * rand_range( 0, 1 ) # a little randomness
	return p0 + v0 * dT # bad prediction








func hit( type, dir, is_dash = false ):
	# Can only be hit by the same type
	if type != TYPE:
		return
	is_hit = true
	if is_dash:
		energy -= 150
	else:
		energy -= 60
	if game.camera: game.camera.shake( 0.25, 60, 4 )
	if energy <= 0:
		emit_signal( "died" )
		create_explosion()
		create_coin( dir )
		queue_free()
		
	else:
		hit_timer = HIT_THROWBACK_TIME
		vel = dir * HIT_THROWBACK
		#if game.camera: game.camera.shake( 0.35, 30, 2 )
	return true




func _on_hitbox_area_entered( area ):
	var p = area.get_parent()
	if p == self: return
	print( p.name, " was bumped into" )
	if p.is_in_group( "bullet_target" ) and p.has_method( "hit" ):
		if p.hit( -1, vel.normalized() ):
			create_explosion()
			hit_cooldown_timer = HIT_PLAYER_COOLDOWN_TIME
			state_nxt = STATES.HIT_COOLDOWN


func create_coin( dir ):
	var x = randf()
#	if x > 0.9:
#		return
	var c = preload( "res://rewards/coin.tscn" ).instance()
	c.position = position
	c.set_dir( dir )
	get_parent().add_child( c )
