extends Node

enum CONTROL_TYPES { MOUSE, GAMEPAD }


var camera setget _set_camera, _get_camera
var player setget _set_player, _get_player
var navigation setget _set_navigation, _get_navigation

var gamestate = { \
		"energy": 100, \
		"maxenergy": 100, \
		"fireshield": 100, \
		"iceshield": 100, \
		"type" : 0, \
		"events": [], \
		"level": "", \
		"coins" : 0, \
		"deaths" : 0, \
		"time" : 0, \
		"bonus" : 0, \
		"startpos": "leave_level_1" } setget _set_gamestate

var main = null
var control_type = CONTROL_TYPES.GAMEPAD#MOUSE#

#===========================
func _set_camera( v ):
	camera = weakref( v )
func _get_camera():
	if camera == null: return null
	return camera.get_ref()
#===========================
func _set_player( v ):
	player = weakref( v )
func _get_player():
	if player == null: return null
	return player.get_ref()
#===========================
func _set_navigation( v ):
	navigation = weakref( v )
func _get_navigation():
	if navigation == null: return null
	return navigation.get_ref()
#===========================
func _set_gamestate( v ):
	gamestate = v
	if main != null: main.update_hud()

func _ready():
	randomize()
	pause_mode = PAUSE_MODE_PROCESS
	reset_gamestate()
	pass

func reset_gamestate():
	gamestate.energy = 100
	gamestate.fireshield = 100
	gamestate.iceshield = 100
	gamestate.events = []
	gamestate.level = ""
	gamestate.startpos = "leave_level_1"
	gamestate.type = 0
	gamestate.coins = 0
	gamestate.deaths = 0
	gamestate.time = 0
	gamestate.bonus = 0

func is_event( evtname ):
	if gamestate[ "events" ].find( evtname ) == -1:
		return false
	return true
func add_event( evtname ):
	if gamestate[ "events" ].find( evtname ) == -1:
		gamestate[ "events" ].append( evtname )
		return true
	return false


enum SFX { STEP, DASH, FIRE_BULLET, BOUNCE_BULLET, EXPLOSION, CHRYSTAL, ALTAR }

func play_sfx( sfx, randompitch = 1 ):
	var m = main.get_node( "sfx" )
	m.set_pitch( randompitch )
	match sfx:
		SFX.STEP:
			m.mplay( preload( "res://sfx/player_step.wav" ) )
		SFX.DASH:
			m.mplay( preload( "res://sfx/playerdash.wav" ) )
		SFX.FIRE_BULLET:
			m.mplay( preload( "res://sfx/bulletstarts_LiamG_SFX_CC0_freesound.wav" ) )
			#m.mplay( preload( "res://sfx/other_bullet_start.wav" ) )
		SFX.BOUNCE_BULLET:
			m.mplay( preload( "res://sfx/bullet_hit_wall.wav" ) )
		SFX.EXPLOSION:
			m.mplay( preload( "res://sfx/bullet_hit_robot.wav" ) )
		SFX.CHRYSTAL:
			m.mplay( preload( "res://sfx/select.wav" ) )
		SFX.ALTAR:
			m.mplay( preload( "res://sfx/altar.wav" ) )




