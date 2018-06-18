extends "res://enemies/enemy.gd"



var bullet_scn = preload( "res://enemies/ice_bullet.tscn" )
var bullet_blast = preload( "res://enemies/explosion.tscn" )
var explosion_scn = preload( "res://enemies/ice_explosion.tscn" )

func _ready():
	TYPE = 1
	$anim.seek( rand_range( 0, 1 ) )
	$blink.seek( rand_range( 0, 8 ) )
	

func _physics_process( delta ):
	update_particles()
	update_states( delta )
	


func create_bullet( bullet_dir ):
	var b = bullet_scn.instance()
	b.global_position = global_position + Vector2( 0, sign( bullet_dir.y ) )
	get_parent().add_child( b )
	return b

func create_bullet_blast():
	var b = bullet_blast.instance()
	get_parent().add_child( b )
	b.set_xplosion_position( position )

func create_explosion():
	var x = explosion_scn.instance()
	x.position = position
	get_parent().add_child(x)