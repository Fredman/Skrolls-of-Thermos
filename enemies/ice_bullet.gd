extends "res://enemies/bullet.gd"

var explosion_scn = preload( "res://enemies/ice_explosion.tscn" ).instance()

func _ready():
	TYPE = 1
	vel *= 0

func _physics_process(delta):
	update_states( delta )

func create_explosion():
	explosion_scn.position = position
	get_parent().add_child(explosion_scn)


func activate():
	$CollisionShape2D.disabled = false
	$hitbox/CollisionShape2D.disabled = false