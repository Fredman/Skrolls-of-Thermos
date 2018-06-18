extends Node2D

signal restart_level
signal finished_level
signal game_over

func _ready():
	game.player.connect( "player_dead", self, "_on_player_dead" )
	game.player.global_position = get_node( game.gamestate.startpos ).get_node( "restart_pos" ).global_position
	game.camera.limit_top = $level_limits/top_left.global_position.y
	game.camera.limit_left = $level_limits/top_left.global_position.x
	game.camera.limit_bottom = $level_limits/bottom_right.global_position.y
	game.camera.limit_right = $level_limits/bottom_right.global_position.x
	
	
	

func _physics_process(delta):
	if Input.is_action_pressed( "btn_quit" ):
		emit_signal( "game_over" )


func is_level():
	return true

func _on_player_dead():
	game.gamestate.deaths += 1
	game.main.get_node( "hud_layer/hud/bonus_counter" ).reset_rewards()
	var t = Timer.new()
	t.one_shot = true
	t.wait_time = 3.0
	t.connect( "timeout", self, "_restart" )
	add_child( t )
	t.start()
func _restart():
	emit_signal( "restart_level" )




# respawning enemies
var MIN_ENEMY_COUNT = 1
var ENEMY_SPAWN_WAIT = 10
var spawn_timer = 0

