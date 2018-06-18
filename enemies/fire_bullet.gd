extends "res://enemies/bullet.gd"

var explosion_scn = preload( "res://enemies/explosion.tscn" ).instance()

func _ready():
	vel *= 0

func _physics_process(delta):
	update_states( delta )

func create_explosion():
	explosion_scn.position = position
	get_parent().add_child(explosion_scn)

func activate():
	$CollisionShape2D.disabled = false
	$hitbox/CollisionShape2D.disabled = false