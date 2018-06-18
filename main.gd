extends Node2D

signal text_finished

const START_SCN = "res://screens/start_screen.tscn"

func _ready():
	game.main = self
	game.gamestate.level = START_SCN
	_load_scene()
	#_load_scene("res://levels/base_level.tscn" )



var load_state = 0
func _load_scene():
	print( "Loading level: ", game.gamestate.level, "   State: ", load_state )
	if load_state == 0:
		# fade out
		$transition_layer/anim.play( "fade_out" )
		load_state = 1
		$loadtimer.set_wait_time( 0.3 )
		$loadtimer.start()
	elif load_state == 1:
		# hide hud
		$hud_layer/hud.hide()
		$hud_layer/hud/hud_text.text = ""
		# clear current act
		var children = $levels.get_children()
		if children.size() > 0:
			if children[0].has_method( "is_level" ):
				_disconnect_level( children[0] )
			children[0].queue_free()
		load_state = 2
		$loadtimer.set_wait_time( 0.1 )
		$loadtimer.start()
	elif load_state == 2:
		# load new act
		var act = load( game.gamestate.level ).instance()
		if act.has_method( "is_level" ):
			_connect_level( act )
		$levels.hide()
		$levels.add_child( act )
		load_state = 3
		$loadtimer.set_wait_time( 0.3 )
		$loadtimer.start()
	elif load_state == 3:
		load_state = 0
		if game.camera != null:
			game.camera.reset_smoothing()
		#show hud
		if $levels.get_child(0).has_method( "is_level" ):
			$hud_layer/hud.show()
		# fade in
		$levels.show()
		$transition_layer/anim.play( "fade_in" )
		# play game
		


func _on_loadtimer_timeout():
	_load_scene()



func _connect_level( v ):
	v.connect( "restart_level", self, "_restart_level" )
	v.connect( "finished_level", self, "_finished_level" )
	v.connect( "game_over", self, "_game_over" )

func _disconnect_level( v ):
	v.disconnect( "restart_level", self, "_restart_level" )
	v.disconnect( "finished_level", self, "_finished_level" )
	v.disconnect( "game_over", self, "_game_over" )

func _restart_level():
	print( "Restarting level: ", game.gamestate.level )
	game.gamestate.energy = 100
	game.gamestate.fireshield = 100
	game.gamestate.iceshield = 100
	_load_scene()
	$hud_layer/hud/bonus_counter.reset_rewards()

func _finished_level():
	_load_scene()

func _game_over():
	game.reset_gamestate()
	$hud_layer/hud/bonus_counter.reset_rewards()
	game.gamestate.level = START_SCN
	_load_scene()

func update_hud():
	#$hud_layer/hud/energy_back/energy.scale.x = game.gamestate.energy / 100.0
	
	$hud_layer/hud/energy_back/energy.polygon[1].x = 4 + game.gamestate.energy / 2.0
	$hud_layer/hud/energy_back/energy.polygon[2].x = 4 + game.gamestate.energy / 2.0
	if game.gamestate.energy > game.gamestate.maxenergy:
		game.gamestate.maxenergy = game.gamestate.energy
	var timestr = "%02d:%02d" % [ floor( game.gamestate.time / 60.0 ), round( game.gamestate.time - floor( game.gamestate.time / 60.0 ) * 60 ) ]
	$hud_layer/hud/timer.text = timestr
	$hud_layer/hud/deathcount.text = "%d" % [game.gamestate.deaths]
		
	

func set_character_text( obj, msg, duration = 2, set_pause = false, wait_for_input = true, offset = Vector2( 0, -32 ) ):
	$hud_layer/hud/hud_text.set_char_text( obj, msg, duration, wait_for_input, offset )
	if set_pause:
		$levels_pause.play( "pause" )
		game.player.set_cutscene()
		get_tree().paused = true
func _on_hud_text_text_finished():
	if get_tree().paused:
		get_tree().paused = false
		game.player.clear_cutscene()
		$levels_pause.play( "unpause" )
	emit_signal( "text_finished" )
	




var count_time = false
func _start_time():
	count_time = true
func _stop_time():
	count_time = false

func _physics_process(delta):
	if count_time:
		game.gamestate.time += delta







