extends KinematicBody2D
signal motion_started



var is_fired = false
var MAX_VEL = 300#500
var MAX_COLLISION = 5
var num_collisions = 0
var vel = Vector2()
var tvel = Vector2()
var is_removed = false
var TYPE = 0 # 0 for fire bullet and 1 for ice bullet

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func set_dir( d ):
	vel = d * MAX_VEL
	
	
func start_motion():
	emit_signal( "motion_started", self )


func update_states( delta ):
	if is_removed: return
	var col = move_and_collide( vel * delta )
	if col != null:
		if game.camera: game.camera.shake( 0.25, 60, 2 )
		num_collisions += 1
		if num_collisions < MAX_COLLISION:
			vel = vel.bounce( col.normal )
			reflect_sfx()
		else:
			stop_bullet()
	#if is_fired and vel.length() < 10: stop_bullet()
		

func _on_visible_screen_exited():
	is_removed = true
	queue_free()

func _on_free_timer_timeout():
	is_removed = true
	queue_free()

func _on_lifetimer_timeout():
	stop_bullet()


func _on_hitbox_area_exited( area ):
	if is_fired: return
	is_fired = true
	$hitbox.connect( "area_entered", self, "_on_hitbox_area_entered" )


var is_hit = false
func _on_hitbox_area_entered( area ):
	if not is_fired:
		return
	if is_hit: return
	var p = area.get_parent()
	#print( p.name, " was hit" )
	if p.is_in_group( "bullet_target" ) and p.has_method( "hit" ):
		if p.hit( TYPE, vel.normalized() ):
			create_explosion()
			stop_bullet()
			is_hit = true
	


var is_stopped = false
func stop_bullet():
	if is_stopped: return
	is_stopped = true
	vel *= 0
	$hitbox.queue_free()
	$CollisionShape2D.queue_free()
	$circle.self_modulate.a = 0.0
	$shadow.hide()
	$circle/Particles2D.emitting = false
	$free_timer.start()




func start_sfx():
	game.play_sfx( game.FIRE_BULLET )

func reflect_sfx():
	game.play_sfx( game.BOUNCE_BULLET, rand_range( 0.8, 1.3 ) )
	pass
















