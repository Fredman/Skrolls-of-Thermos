extends Node2D


func _ready():
	# game stats
	var score = round( min( game.gamestate.coins - game.gamestate.deaths, 0 ) * max( 1, game.gamestate.maxenergy - game.gamestate.time / 20 ) )
	
	score = 1000 * game.gamestate.coins + \
			10 * game.gamestate.maxenergy
	if game.gamestate.deaths > 10:
		score += 200 * game.gamestate.deaths
	else:
		score -= 1000 * game.gamestate.time / 60
	score += game.gamestate.bonus
	score = round( score )
	
	var timestr = "%02d:%02d" % [ floor( game.gamestate.time / 60.0 ), round( game.gamestate.time - floor( game.gamestate.time / 60.0 ) * 60 ) ]
	var statsstr = "%s\n" % [timestr]
	statsstr += "%d\n" % [game.gamestate.deaths]
	statsstr += "%d\n" % [game.gamestate.coins]
	statsstr += "%d\n" % [game.gamestate.maxenergy]
	statsstr += "%d\n\n" % [game.gamestate.bonus]
	statsstr += "%d\n" % [score]
	$stats/gamestats.text = statsstr
	
	
	set_process_input( true )


#func _on_Button_pressed():
#	print( "START GAME" )
#	game.reset_gamestate()
#	game.main._load_scene( "res://levels/base_level.tscn" )
	

func _input(event):
	if event.is_action( "btn_fire" ) or event.is_action( "btn_quit" ):
		game.reset_gamestate()
		game.gamestate.level = "res://screens/start_screen.tscn"
		game.main._stop_time()
		game.main._load_scene()