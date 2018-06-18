extends Area2D
export( bool ) var active = true
export( String, FILE ) var LeaveTo = ""
export( String ) var StartNode = "leave_level_1"
func _ready():
	pass



var activated = false
func _on_leave_level_body_entered(body):
	if not active: return
	if activated: return
	activated = true
	game.gamestate.level = LeaveTo
	game.gamestate.startpos = StartNode
	get_parent().emit_signal( "finished_level" )
