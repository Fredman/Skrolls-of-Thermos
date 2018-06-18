extends Node2D


func _ready():
	Input.set_mouse_mode( Input.MOUSE_MODE_VISIBLE )
	set_process_input( true )


#func _on_Button_pressed():
#	print( "START GAME" )
#	game.reset_gamestate()
#	game.main._load_scene( "res://levels/base_level.tscn" )
	

var start_selected = false
func _input(event):
	
	if start_selected: return
	start_selected = true
	
	game.reset_gamestate()
	game.gamestate.level = "res://levels/level_01.tscn"
	#game.gamestate.level = "res://levels/level_07.tscn"
	# Add test events!
	
#	game.add_event( "WASD tutorial" )
#	game.add_event( "shield" )
#	game.add_event( "ice" )
#	game.add_event( "dash" )
#	game.add_event( "complete altar" )
	
	if event.is_action( "btn_quit" ):
		get_tree().quit()
		return
	
	if event is InputEventJoypadButton:
		print( "gamepad mode" )
		Input.set_mouse_mode( Input.MOUSE_MODE_HIDDEN )
		game.control_type = game.GAMEPAD
		game.main._start_time()
		game.main._load_scene()
	elif event is InputEventMouseButton:
		print( "mouse mode" )
		game.control_type = game.MOUSE
		game.main._start_time()
		game.main._load_scene()
	else:
		start_selected = false
	
	return

		
	
