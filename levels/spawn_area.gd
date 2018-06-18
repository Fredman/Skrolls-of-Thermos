extends Area2D
signal spawning_enemies

var fire_enemy_scn = preload( "res://enemies/fire_enemy.tscn" )
var ice_enemy_scn = preload( "res://enemies/ice_enemy.tscn" )
var positions = []
var active_enemies = 0
var first_spawn = false

func _ready():
	for c in get_children():
		if c is preload( "res://levels/position_type.gd" ):
			positions.append( c )

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_spawn_area_body_entered(body):
	if first_spawn: return
	first_spawn = true
	print( body.name, " entered spawn area" )
	if game.player == null: return
	if body != game.player: return
	
	# check if needs spawning
	if active_enemies == 0:
		print( "Spawning enemies in ", $respawn_timer.wait_time, " s" )
		$respawn_timer.start()
		

func _on_respawn_timer_timeout():
	emit_signal( "spawning_enemies" )
	for p in positions:
		var e = null
		if p.type == 0:
			print( "spawning fire enemy" )
			e = fire_enemy_scn.instance()
		else:
			print( "spawning ice enemy" )
			e = ice_enemy_scn.instance()
		e.global_position = p.global_position
		# todo: set enemy type
		get_parent().add_child( e )
		e.connect( "died", self, "_enemy_died" )
		active_enemies += 1

func _enemy_died():
	active_enemies -= 1
